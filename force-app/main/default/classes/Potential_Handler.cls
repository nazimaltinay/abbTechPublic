public with sharing class Potential_Handler {
 
    public class localException extends Exception{}

    @AuraEnabled
     public static void ConvertPotentialToOpportunity(string accountId)
    {
        system.debug('Conversion started Id -->'+ accountId);

        //get standard price book. 
        string priceBookId =    Potential_Handler.getStdPriceBook();
        List<Potential__c> ptnslS = [SELECT Id, Name, Total_volume__c, Product__r.Id, Product__r.ProductCode, Account__r.Id FROM Potential__c where Account__r.Id = : accountId];
        
        // Get product Id to use lower system limit.
        // It will be used to filter PriceBookEntry
        Set<String> prodIds = new Set<String>();
        for(Potential__c ptnsl: ptnslS )
        { 
            prodIds.add(ptnsl.Product__r.Id);
        }

        //Get related pricebook entries.
        //map list according to product Id. It will be inside iteration.
        //Keep safe against governor limit
        List<PricebookEntry> pbeS = [SELECT Pricebook2Id, Product2Id, UnitPrice, IsActive, Id  FROM PricebookEntry where IsActive = true and Pricebook2Id = : priceBookId and Product2Id in :prodIds];
        Map<string, PricebookEntry> pbEntrieS  = new Map<String, PricebookEntry>();
        for(PricebookEntry pbE: pbeS)
        { 
            pbEntrieS.put(pbe.Product2Id, pbe);
        }

        //Insert Opportunity.
        //Set mandatory fields.
        Opportunity opp = new Opportunity();
        opp.AccountId = accountId;
        opp.CloseDate =  Date.today().adddays(7);
        opp.Name = 'Converted from potential:'+ Date.today();
        opp.StageName = 'Prospecting';
        opp.Pricebook2Id = priceBookId;
        
        try {
            Insert opp;
        } catch (Exception ex) {
            throw new localException ('Opportunity could not be created. Reason is : '+ex.getMessage() );
        }
        

        //Create Opportunity lines. Opportunity Line Item is related with Potential record on Related_Potential__c.
        //Throw error message incase of any product doesn't have price book entry. 
        List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>();
        for(Potential__c ptnsl: ptnslS )
        {   
            PricebookEntry pbEntry = pbEntrieS.get(ptnsl.Product__r.Id);
            if(pbEntry == null)
            {
                throw new localException ('Price is not defined for Product:'+ ptnsl.Product__r.ProductCode);
            }
            OpportunityLineItem oppLine = new OpportunityLineItem();
            oppLine.OpportunityId = opp.Id;
            oppLine.Product2Id = ptnsl.Product__r.Id;
            oppLine.Quantity = ptnsl.Total_volume__c;
            oppLine.TotalPrice = ptnsl.Total_volume__c * pbEntry.UnitPrice;
            oppLine.Related_Potential__c = ptnsl.Id;
            oppLines.add(oppLine);
        }
        try {
            Insert oppLines;
        } catch (Exception ex) {
            throw new localException ('Opportunity could not be created because of product error. Detailed reason is : '+ex.getMessage() );
        }
    }

    //get system standard price list.
    //prevent error during test. Test coverage will be reduced!
    public static String  getStdPriceBook () {
        if(Test.isRunningTest()) return test.getStandardPricebookId();
        Pricebook2  stdPriceBook    = [select id, name from Pricebook2 where isStandard = true limit 1];
        return stdPriceBook.Id;    
    }
}

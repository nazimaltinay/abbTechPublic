public with sharing class PotentialController {
 
    @AuraEnabled(cacheable = true)
    public static List<Potential__c> getPotentialList(string recordId, string pricebookName, string productFamily )
    {
        List<Potential__c> ptnslS = [SELECT Id, Name, Total_volume__c, Product__r.Id, Product__r.ProductCode,  Product__r.Name, Product__r.Family, Account__r.Id, Destination_location__c,  Origin_location__c  
        FROM Potential__c where Account__r.Id = : recordId and Product__r.Family= : productFamily];

        Set<String> prodIds = new Set<String>();
        for(Potential__c ptnsl: ptnslS )
        { 
            prodIds.add(ptnsl.Product__r.Id);
        }
        
        List<PricebookEntry> pbeS = [SELECT Pricebook2Id, Product2Id, UnitPrice, IsActive, Id FROM PricebookEntry 
        where Pricebook2Id IN (SELECT Id FROM PriceBook2  WHERE Name = :pricebookName) and IsActive=true and Product2Id in :prodIds];
        Map<string, PricebookEntry> pbEntrieS  = new Map<String, PricebookEntry>();
        for(PricebookEntry pbE: pbeS)
        { 
            pbEntrieS.put(pbe.Product2Id, pbe);
        }

        List<Potential__c>  rtPotentials = new List<Potential__c>();
        for(Potential__c ptnsl: ptnslS )
        {   
            PricebookEntry pbEntry = pbEntrieS.get(ptnsl.Product__r.Id);
            if(pbEntry != null)
            {
                rtPotentials.add(ptnsl);
            }
 
        }
        return rtPotentials;
    }

    @AuraEnabled(cacheable = true)
    public static List<PriceBook2> getPriceListNames()
    {
        List<PriceBook2> pLists = [SELECT Name from PriceBook2];
        return pLists;
    }
 

    
    @AuraEnabled
    public static string createOpportunity(string accountId, string priceBookId){
        try {
        //Insert Opportunity.
        //Set mandatory fields.
        Opportunity opp = new Opportunity();
        opp.AccountId = accountId;
        opp.CloseDate =  Date.today().adddays(7);
        opp.Name = 'Converted from potential LWC:'+ Date.today();
        opp.StageName = 'Prospecting';
        opp.Pricebook2Id = priceBookId;
        insert opp;
        return opp.Id;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string createOpportunity(List<String> Potentials, string OpportunityId ){
        try {
        //Create Opportunity lines. Opportunity Line Item is related with Potential record on Related_Potential__c.
        List<Potential__c> ptnslS = [SELECT Id, Name, Total_volume__c, Product__r.Id, Product__r.ProductCode,  Product__r.Name, Product__r.Family, Account__r.Id, Destination_location__c,  Origin_location__c  
        FROM Potential__c where Id in: Potentials ];

        List<PricebookEntry> pbeS = [SELECT Pricebook2Id, Product2Id, UnitPrice, IsActive, Id FROM PricebookEntry 
        where Pricebook2Id IN (SELECT Id FROM PriceBook2  WHERE Name = :pricebookName) and IsActive=true and Product2Id in :prodIds];
        Map<string, PricebookEntry> pbEntrieS  = new Map<String, PricebookEntry>();
        for(PricebookEntry pbE: pbeS)
        { 
            pbEntrieS.put(pbe.Product2Id, pbe);
        }

        List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>();
        for(Potential__c ptnsl: ptnslS )
        {   
            OpportunityLineItem oppLine = new OpportunityLineItem();
            oppLine.OpportunityId = OpportunityId ;
            oppLine.Product2Id = ptnsl.Product__r.Id;
            oppLine.Quantity = ptnsl.Total_volume__c;
            oppLine.TotalPrice = ptnsl.Total_volume__c * pbEntry.UnitPrice;
            oppLine.Related_Potential__c = ptnsl.Id;
            oppLines.add(oppLine);
        }
        Insert oppLines;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}

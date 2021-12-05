@istest
public with sharing class Potential_Handler_Test {
    @TestSetup
    static void makeData(){
        Account acc = new Account(Name='Account for test');
        Insert acc;

        Product2 prod = new Product2( Name='Test Product', IsActive=true, ProductCode = 'Pro-001' );
        Insert prod;
 

        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        Insert pbEntry;

        List<Potential__c> potnlS = new List<Potential__c>();
        for(Integer i = 0; i<250; i++)
        {
            Potential__c potnl = new Potential__c (
                Account__c = acc.Id,
                Product__c = prod.Id,
                Total_volume__c = 1000+i
            );
            potnlS.add(potnl);
        }
        insert  potnlS;
        system.debug('Potential Size' + potnlS.size());
    }
    @istest static void ConvertPotentialToOpportunity_test()
    {
        List<Account> acc = [Select Id from  Account where Name='Account for test'  ];
        
        string accId = acc[0].Id;

        System.debug('Test Account Id -->' +accId);
        Test.startTest();
        Potential_Handler.ConvertPotentialToOpportunity(accId);
        Test.stopTest();

        List<OpportunityLineItem> opplines = [Select Id, ProductCode from OpportunityLineItem where ProductCode = 'Pro-001'];
        Integer actValue = opplines.size();
        system.assertEquals(250, actValue);

    }

}
git -push
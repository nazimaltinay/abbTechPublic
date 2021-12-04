public with sharing class PotentialController {
 

    @AuraEnabled(cacheable = true)
    public static List<Potential__c> getPotentialList(string recordId)
    {
        List<Potential__c> ptnslS = [SELECT Id, Name, Total_volume__c, Product__r.Id, Product__r.ProductCode,  Product__r.Name, Account__r.Id, Destination_location__c,  Origin_location__c FROM Potential__c where Account__r.Id = : recordId];
        return ptnslS;
    }
}

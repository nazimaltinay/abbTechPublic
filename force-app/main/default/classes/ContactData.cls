public with sharing class ContactData {
    public static List<Contact> getContactList(string accountId )
    {
        return [Select Id, FirstName, LastName from Contact where account.Id = :accountId ];
    }
}

/**
* @author Ivan Yeung
* @date 2020
*
* @group CRMCore
* @group-content ../../ApexDocContent/CRMCore.htm
*
* @description Implementation of data mapper selector 

Force.com Note: This pattern is an ideal place to place CRUD security checks for permission to read. It also helps avoid runtime exceptions relating to fields referenced that have not been queried. Since it can help form and encapsulate a consistent place for placing code relating to querying data as apposed to spreading adhoc SOQL queries throughout your logic.


*/
public with sharing class AccountSelector  extends fflib_SObjectSelector {
    
    private List <ObjectFieldSelection__mdt> objectFieldListMeta; 
    
    public AccountSelector(List <String> metadataNames) {
        objectFieldListMeta  = [select DeveloperName, FieldList__c, ObjectName__c from ObjectFieldSelection__mdt where DeveloperName =: metadataNames ]; 
    }

    public AccountSelector() {
        objectFieldListMeta  = [select DeveloperName, FieldList__c, ObjectName__c from ObjectFieldSelection__mdt where ObjectName__c = 'Account']; 
    }




    public List<Schema.SObjectField> getSObjectFieldList()
	{

        Set<Schema.SObjectField>  objectFieldSet = new Set<Schema.SObjectField>();
        Map<String, Schema.SObjectField> accountFields =  Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap(); 
        System.debug('Account Fields: ' + accountFields); 

        // standard fields 
        objectFieldSet.Add(Account.Id); 
        objectFieldSet.Add(Account.Name);

        if (objectFieldListMeta != null){
            for (ObjectFieldSelection__mdt objSelection: objectFieldListMeta){
                if (objSelection.ObjectName__c == 'Account'){

                    /* format of JSON 
                        { 
                           fieldList: ["website", "custom1__c"]     
                        }
                    */
                    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(objSelection.FieldList__c);
                    For (Object a: (List<Object>)m.get('fieldList')){
                        String fieldname = ((String)a).toLowerCase(); 
                        System.debug('included fieldname: ' + fieldname);  // this is the API of the fieldList
                        if (accountFields.containsKey(fieldname)){
                            objectFieldSet.Add(accountFields.get(fieldname));
                        }
                    }
                }
            }
        }

        List <Schema.SObjectField>  objectFieldList = new List <Schema.SObjectField> ();
        objectFieldList.addAll(objectFieldSet);

        return objectFieldList; 

	}
	
	public Schema.SObjectType getSObjectType()
	{
		return Account.sObjectType;
	}

	public List<Account> selectById(Set<ID> idSet)
	{
		return (List<Account>) selectSObjectsById(idSet);
	}


}

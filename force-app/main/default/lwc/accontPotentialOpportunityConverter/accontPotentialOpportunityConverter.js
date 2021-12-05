import { LightningElement, wire, api, track } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import Family_FIELD from '@salesforce/schema/Product2.Family';
import  getPotentialList  from "@salesforce/apex/PotentialController.getPotentialList";
import  getPriceListNames  from "@salesforce/apex/PotentialController.getPriceListNames";

const columns = [
            {
                label: "Name",
                fieldName: "Name",
                type: "text"
            },
          {
            label: "Product Name",
            fieldName: "Productname",
            type: "text"
          },
          {
            label: "Origin",
            fieldName: "Origin_location__c",
            type: "text"
          },
          {
            label: "Destination Location",
            fieldName: "Destination_location__c",
            type: "text"
          },
          {
            label: "Total Volume",
            fieldName: "Total_volume__c",
            type: "number"
          }

        ]

export default class AccontPotentialOpportunityConverter extends LightningElement {

    @api recordId;
    @track error;
    @track potentialList;
    columns = columns;
    selectedRecords = [];
    @track recordsCount
    @track pricelistsvalues;
    xfamily;
    xpricebook;

    @wire(getPotentialList, {recordId: "$recordId", pricebookName:'$xpricebook', productFamily :'$xfamily'}) 
    potentials({ 
        error, 
        data 
    }) {
          console.log('get values.');
          if(data)
          {

            this.potentialList = data.map(row=>{ 
              return{...row, Productname:row.Product__r.Name}
            });
            console.log('Potential List-->'+this.potentialList  );
            /*
            */
          } else if(error)
          {
            console.log('error -->'+ error );
            this.error = error;

          }
      }


      getSelectedRecords(event) {
        // getting selected rows
        const selectedRows = event.detail.selectedRows;
        this.recordsCount = event.detail.selectedRows.length;
        // this set elements the duplicates if any
        let conIds = new Set();
    
        // getting selected record id
        for (let i = 0; i < selectedRows.length; i++) {
          conIds.add(selectedRows[i].Id);
        }
        console.log('Selected Ids -->' + conIds);
        // coverting to array
        this.selectedRecords = Array.from(conIds);
      }

      handleConvertionRequest() {
         console.log('Convertion Button');
        if (this.recordsCount == 0) {
          console.log("Selected Line Count is 0 -->", this.recordsCount);
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'No selection',
              message: ' There is no selected line.',
              variant: "warning",
              mode: "sticky"
            })
          );
          return;
        }
 
        if (this.selectedRecords) {
            var selectedRows = this.template
            .querySelector("lightning-datatable")
            .getSelectedRows();
           
            Promise.all(
                selectedRows.map(element => {
                   var potentialId = element.Id;
                    console.log('Potential Id -->'+ potentialId);
    
                }
                )
            );
    
 
        }
      }
      submitCreate() {

      }
      @wire(getObjectInfo, { objectApiName: PRODUCT_OBJECT })
      objectInfo;
      
      @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Family_FIELD})
      FamilyFieldPicklistValues;
      
      /// Get values from page
      handleChange(event) {
        const field = event.target.name;
        if (field === "productfamily") {
          this.xfamily= event.target.value;
        } else if(field === "pricebookName")
        {
          this.xpricebook =  event.target.value;
        }
        refreshApex(this.potentialList );
      } 

      /// # Price lists
      @wire(getPriceListNames) priceBooks;
      get pricebookValues()
      {
        var returnOptions = [];
        if(this.priceBooks.data){
            this.priceBooks.data.forEach(ele =>{
                returnOptions.push({label:ele.Name , value:ele.Name});
            }); 
        }
        console.log(JSON.stringify(returnOptions));
        return returnOptions;
      }
}
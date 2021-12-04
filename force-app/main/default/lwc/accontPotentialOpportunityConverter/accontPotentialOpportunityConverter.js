import { LightningElement, wire, api, track } from "lwc";
import  getPotentialList  from "@salesforce/apex/PotentialController.getPotentialList";

const columns = [
            {
                label: "Name",
                fieldName: "Name",
                type: "text"
            },
          {
            label: "Product Name",
            fieldName: "Product__r.Name",
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

    @wire(getPotentialList, {recordId: "$recordId"}) 
    potentials({ 
        error, 
        data 
    }) {
          if(data)
          {
            this.potentialList = data;
          } else if(error)
          {
            this.error = error;
            console.log('error -->'+ error );
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
}
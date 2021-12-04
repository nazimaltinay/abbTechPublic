import { LightningElement, wire, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import { getPotentialList } from "@salesforce/apex/Potential_Handler.getPotentialList";


export default class AccountPotentialList extends LightningElement {
    @api recordId;
    potentialList;

    @wire(getPotentialList, {
        recordId: "$recordId"
      })
      potentialList(result) {
        this.potentialList = result;
      }
 
    }
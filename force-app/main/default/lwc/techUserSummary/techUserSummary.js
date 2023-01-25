import { api, LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getSRObj from '@salesforce/apex/techDashboard.getSRInfo';
import techId from '@salesforce/user/Id';
import customlabelUserTitle from "@salesforce/label/c.UserTitle";
import customlabelUserName from "@salesforce/label/c.UserName";
import customlabelUserLastLocationDate from "@salesforce/label/c.UserLastLocationDate";

export default class getSRInfo extends LightningElement {
    @track srData = [];
    @track errorData;    
    labels = {
        customlabelUserTitle,
        customlabelUserName,
        customlabelUserLastLocationDate
    };
    @wire(getSRObj,{userId : techId})
    dataRecord({data, error}){
        if(data){
            this.srData = data;
        }
        else if(error){
            this.errorData = error;
        }
    }
    get techName() {
        return this.srData.Name;
    }   
    get techLastDate() {
        return this.srData.LastKnownLocationDate;
    }   
}
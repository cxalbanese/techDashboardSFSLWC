import { api, LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getSAList from '@salesforce/apex/techDashboard.getSAInfo';
import techId from '@salesforce/user/Id';
import customlabelServiceAppointmentTitle from "@salesforce/label/c.ServiceAppointmentTitle";
import customlabelOpenServiceAppointments from "@salesforce/label/c.OpenServiceAppointments"; 
export default class getSAs extends LightningElement {
    @track saData = [];
    @track errorData;
    labels = {
        customlabelServiceAppointmentTitle,
        customlabelOpenServiceAppointments
    };
    @wire(getSAList,{userId : techId})
    dataRecord({data, error}){
        if(data){
            this.saData = data;
        }
        else if(error){
            this.errorData = error;
        }
    }
    get numOpenSAs() {
        return this.saData.length;
    }   
}
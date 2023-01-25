import { api, LightningElement, track, wire } from 'lwc';
import getWOList from '@salesforce/apex/techDashboard.getWOInfo';
import techId from '@salesforce/user/Id';
import customlabelWorkOrderTitle from "@salesforce/label/c.WorkOrderTitle";
import customlabelContractWorkOrders from "@salesforce/label/c.ContractWorkOrders";
import customlabelSpotWorkOrders from "@salesforce/label/c.SpotWorkOrders"; 
import customlabelProjectWorkOrders from "@salesforce/label/c.ProjectWorkOrders";  

export default class getWOs extends LightningElement {
    @track wt1Label='';
    @track wt1Num=0;
    @track wt2Label='';
    @track wt2Num=0;
    @track wt3Label='';
    @track wt3Num=0;
    @track wt2Available=false;
    @track wt3Available=false;
    labels = {
    customlabelSpotWorkOrders,
    customlabelProjectWorkOrders,
    customlabelContractWorkOrders,
    customlabelWorkOrderTitle
};
    @track WOData = [];
    @track woMap = new Map();
    @track errorData;
    @wire(getWOList,{userId : techId})
    dataRecord({data, error}){
       if(data){
            this.WOData = data;
            let wtKey='None';
            let innerWoMap = this.woMap;
            this.WOData.forEach(WOFunction);
            function WOFunction(value) {
                if(value.WorkType && value.WorkType.Name) {
                    wtKey = value.WorkType.Name;
                }
                else {
                    wtKey = 'None';    
                }                
                if(innerWoMap.has(wtKey)) {
                    innerWoMap.set(wtKey,innerWoMap.get(wtKey)+1);
                }
                else {                       
                    innerWoMap.set(wtKey,1); 
                }                   
            }
            this.woMap = innerWoMap;
            let max=[];
            //find the largest value in the map of wt:numWO and store in wt1
            if(this.woMap.size>0) {
                max = [...this.woMap.entries()].reduce((accumulator, element) => {
                    return element[1] > accumulator[1] ? element : accumulator;
                    });
                this.wt1Label=max[0];
                this.wt1Num=max[1];
                //remove the largest value for the next pass
                this.woMap.delete(max[0]);
            }
            //find the next largest value in the map of wt:numWO and store in wt2
            if(this.woMap.size>0) {
                max = [...this.woMap.entries()].reduce((accumulator, element) => {
                    return element[1] > accumulator[1] ? element : accumulator;
                    });
                this.wt2Label=max[0];
                this.wt2Num=max[1];
                this.wt2Available=true;
                //remove the largest value for the next pass
                this.woMap.delete(max[0]);
            }
            //find the next largest value in the map of wt:numWO and store in wt3
            if(this.woMap.size>0) {
                max = [...this.woMap.entries()].reduce((accumulator, element) => {
                    return element[1] > accumulator[1] ? element : accumulator;
                    });
                this.wt3Label=max[0];
                this.wt3Num=max[1];
                this.wt3Available=true;
                //remove the largest value for the next pass - in case you add a 4th pass
                this.woMap.delete(max[0]);
            }
       }
       else if(error){
           this.errorData = error;
       }
     }

    get numWOs() {
        return this.WOData.length;
    } 
    get wt1FieldLabel() {
        if(this.wt1Label) {
            return this.wt1Label;
        }
        else {
            return '';
        }
    }
    get wt2FieldLabel() {
        if(this.wt2Label) {
            return this.wt2Label;
        }
        else {
            return '';
        }
    }
    get wt3FieldLabel() {
        if(this.wt3Label) {
            return this.wt3Label;
        }
        else {
            return '';
        }
    }
    get numContractWOs() {
        return(this.numWOCat('Battery Replacement'));
    }   
    get numProjectWOs() {
        return(this.numWOCat('Maintenance'));
    }    
    get numSpotWOs() {
        return(this.numWOCat('Installation'));
    }   

    numWOCat(cat) {        
        let numCat=0;
        this.WOData.forEach(WOFunction);
        function WOFunction(value) {
            if(value.WorkType && value.WorkType.Name) {
                if(value.WorkType.Name==cat) {
                    numCat++;
                }       
            }
        }
        return numCat;
    }  
}
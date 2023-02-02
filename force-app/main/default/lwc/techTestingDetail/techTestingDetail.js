debugger
import {api, LightningElement } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';

export default class TechTestingDetail extends LightningElement {
    @api myrow;
    @api key;

    // delete everything below - its testing
    redirectToObjectDetails(row)  {
        const abc = row;
        const edf = this.myrow;
        const keyin = this.key;
        console.log('row abc = ' + abc + ' edf ' + edf + ' key ini ' + keyin);
        const objid =  '08p8c0000007Y2QAAU';
        const navUrl = `com.salesforce.fieldservice://v1/sObject/${objid}/details`;  
        this[NavigationMixin.Navigate]({
          type: 'standard__webPage',
          attributes: {
            url: navUrl
            }
          });
      } 

}
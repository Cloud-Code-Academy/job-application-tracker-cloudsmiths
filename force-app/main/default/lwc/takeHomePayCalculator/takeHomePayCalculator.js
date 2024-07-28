import { LightningElement, track } from 'lwc';

export default class TakeHomePayCalculator extends LightningElement {

    @track currentResult = 0;
    income = 0;
    federalTax = 0.12;
    socialSecurity = 0.062;
    medicare = 0.0145;

    inputChangeHandler(event){
        const inputBoxName = event.target.name;

        if(inputBoxName === 'income'){
            this.income = event.target.value;
        } else if (inputBoxName === 'federalTax'){
            this.federalTax = event.target.value;
        } else if (inputBoxName === 'socialSecurity'){
            this.socialSecurity = event.target.value;
        } else if (inputBoxName == 'medicare'){
            this.medicare = event.target.value;
        }
    }

    calculateHandler(){
        const incomeValue = parseFloat(this.income);
        const fedTaxValue = parseFloat(this.federalTax);
        const socialSecValue = parseFloat(this.socialSecurity);
        const medicareValue = parseFloat(this.medicare);

        let calculatedValue = parseFloat(incomeValue - (fedTaxValue * incomeValue) - (socialSecValue * incomeValue) - (medicareValue * incomeValue));

        this.currentResult = `
        Your Annual Take Home Pay is $${calculatedValue.toFixed(2)}
        Your Monthly Take Home Pay is $${(calculatedValue / 12).toFixed(2)}
        Your Bi-Weekly Take Home Pay is $${(calculatedValue / 26).toFixed(2)}
        Your Weekly Take Home Pay is $${(calculatedValue / 52).toFixed(2)}`;
    }
}
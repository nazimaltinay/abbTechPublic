({  
    
    onInit : function( component, event, helper ) {    
            var pAction = component.get("c.ConvertPotentialToOpportunity");
            var recId = component.get("v.recordId") ;
            pAction.setParams({ accountId: recId });
            
            pAction.setCallback(this, function(pCallback){
                    console.log('##State--->'+pCallback);
                    if(pCallback.getState() === "SUCCESS"){
 
                        console.log("###### SUCCESS");

                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: 'Potential(s) are converted to opportunity',
                            type:'success',
                            mode:'sticky'
                        });
                        toastEvent.fire();
                        console.log("###### SUCCESS");
                        $A.get("e.force:closeQuickAction").fire() 
                    } else
                    {
                        var errors = pCallback.getError();
                        console.log("Error message: " + 
                        errors[0].message);
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: 'Error occurred during convertion: ' + errors[0].message,
                            type:'error',
                            mode:'sticky'
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire() 
                    }
            	}
            ) //Set call back
            $A.enqueueAction(pAction);
            
        
    }
    
})
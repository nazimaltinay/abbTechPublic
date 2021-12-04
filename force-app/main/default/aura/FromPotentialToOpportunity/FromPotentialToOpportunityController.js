({  
    
    onInit : function( component, event, helper ) {    
        /*
        var action = component.get( "c.ConvertPotentialToOpportunity" );  
        action.setParams({  
            accountId: component.get( "v.recordId" ),
        });  
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                 console.log('Sucess');
            } else
            {
                console.log('Error');
            }
        });
        $A.enqueueAction(action); 
          */   

            //Contact Count
            var pAction = component.get("c.ConvertPotentialToOpportunity");
            var recId = component.get("v.recordId") ;
            pAction.setParams({ accountId: recId });
            pAction.setCallback(this, function(pCallback){
                    if(pCallback.getState() === "SUCCESS"){
 ;
                        console.log("###### SUCCESS");

                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: 'Potential(s) are converted to opportunity',
                            type:'success',
                        });
                        toastEvent.fire();

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
                    }
            	}
            ) //Set call back
            $A.enqueueAction(pAction);
            $A.get("e.force:closeQuickAction").fire() 
        
    }
    
})
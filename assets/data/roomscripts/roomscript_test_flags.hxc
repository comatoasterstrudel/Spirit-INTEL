function CTSCRIPT_SETNAME():String
{
	return "test_flags";
}

var coworkerA:Character;
var coworkerB:Character;

var interactable_coworkerA1:Interactable;
var interactable_coworkerA2:Interactable;
var interactable_coworkerAMad:Interactable;

var interactable_coworkerB1:Interactable;
var interactable_coworkerB2:Interactable;
var interactable_coworkerBMad:Interactable;

function create(){    
    coworkerA = getCharacterByTag("coworkerA");
    coworkerB = getCharacterByTag("coworkerB");
    
    interactable_coworkerA1 = getInteractableByTag("coworkerA1");
    interactable_coworkerA2 = getInteractableByTag("coworkerA2");
    interactable_coworkerAMad = getInteractableByTag("coworkerAMad");

    interactable_coworkerB1 = getInteractableByTag("coworkerB1");
    interactable_coworkerB2 = getInteractableByTag("coworkerB2");
    interactable_coworkerBMad = getInteractableByTag("coworkerBMad");
    
    for(interactable in [interactable_coworkerA1, interactable_coworkerA2, interactable_coworkerAMad]){
        interactable.setPosition(coworkerA.x, coworkerA.y);
    }
    
    for(interactable in [interactable_coworkerB1, interactable_coworkerB2, interactable_coworkerBMad]){
        interactable.setPosition(coworkerB.x, coworkerB.y);
    }
    
    updateInteractables();
}

function updateInteractables():Void{
    interactable_coworkerA1.disabled = false;
    interactable_coworkerA2.disabled = true;
    interactable_coworkerAMad.disabled = true;
        
    interactable_coworkerB1.disabled = false;
    interactable_coworkerB2.disabled = true;
    interactable_coworkerBMad.disabled = true;
        
    if(Save.storyFlags.get("test_interactedWithCoworkerAFirst").val_bool){
        interactable_coworkerA1.disabled = true;
        interactable_coworkerA2.disabled = false;
        interactable_coworkerAMad.disabled = true;
        
        interactable_coworkerB1.disabled = true;
        interactable_coworkerB2.disabled = true;
        interactable_coworkerBMad.disabled = false;
    } else if(Save.storyFlags.get("test_interactedWithCoworkerBFirst").val_bool){
        interactable_coworkerA1.disabled = true;
        interactable_coworkerA2.disabled = true;
        interactable_coworkerAMad.disabled = false;
        
        interactable_coworkerB1.disabled = true;
        interactable_coworkerB2.disabled = false;
        interactable_coworkerBMad.disabled = true;
    }
}

function talkedToCoworkerA():Void{        
    Save.storyFlags.get("test_interactedWithCoworkerAFirst").val_bool = true;
    Save.storyFlags.get("test_interactedWithCoworkerBFirst").val_bool = false;
    
    updateInteractables();   
}

function talkedToCoworkerB():Void{
    Save.storyFlags.get("test_interactedWithCoworkerAFirst").val_bool = false;
    Save.storyFlags.get("test_interactedWithCoworkerBFirst").val_bool = true;
    
    updateInteractables();   
}
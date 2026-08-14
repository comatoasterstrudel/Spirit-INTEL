package battle.ai;

class UnitAi
{
    var unit:Unit;
    var allyGrid:Grid;
    var enemyGrid:Grid;

    var pointsPerSkill:Map<SkillData, Int> = [];

    public function new(unit:Unit, allyGrid:Grid, enemyGrid:Grid):Void{
        this.unit = unit;
        this.allyGrid = allyGrid;
        this.enemyGrid = enemyGrid;
    }

    public function getSkill():UnitAIDecision{        
        var mpAllowedSkills:Array<SkillData> = getMpAllowedSkills(unit.skills);

        var availableSkills:Array<SkillData> = getAvailableSkills(mpAllowedSkills);

        if(availableSkills.length <= 0){
            return{skillData: null, unit: unit, grid: enemyGrid, position: FlxPoint.get(1,1)};
        }

        var advantages = setAdvantageSpots(availableSkills);

        return(getFinalDecision(availableSkills, advantages));
    }

    function getMpAllowedSkills(startingSkills:Array<SkillData>):Array<SkillData>
    {
        var skills:Array<SkillData> = [];

        for(skill in startingSkills){
            if(skill.mpCost <= unit.mp.value){
                skills.push(skill);
            }    
        }

        return skills;
    }

    /**
     * check all skills and see which ones are able to affect units
     * @param startingSkills the full list of skills
     * @return Array<SkillData> the skills which will have an effect
     */
    function getAvailableSkills(startingSkills:Array<SkillData>):Array<SkillData>{
        var skills:Array<SkillData> = [];

        for(skill in startingSkills){
            var availableSpaces = PlayState.getAvailableSpacesForSkillType(skill.selectType, unit, [allyGrid, enemyGrid]);

            var spacesWithUnits:Array<GridSpace> = [];

            for(space in availableSpaces){
                var affectedSpacesWithUnits:Int = 0;

                for(affectedSpace in PlayState.getAffectedSpacesForSkill(skill, unit, space.grid, space.position)){
                    if(affectedSpace.unit != null) affectedSpacesWithUnits ++;
                }

                if(affectedSpacesWithUnits > 0){
                    spacesWithUnits.push(space);
                }
            } 

            if(spacesWithUnits.length > 0){
                skills.push(skill);
            }
        }

        return skills;
    }

    /**
     * Find out the most advantageous spots to use each skill
     * @param skills 
     * @return Map<SkillData, GridSpace>
     */
    function setAdvantageSpots(skills:Array<SkillData>):Map<SkillData, GridSpace>{
        var advantages:Map<SkillData, GridSpace> = [];

        for(skill in skills){
            var highestPoints:Int = -1;

            for(space in PlayState.getAvailableSpacesForSkillType(skill.selectType, unit, [allyGrid, enemyGrid])){
                var points:Int = 0;

                for(affectedSpace in PlayState.getAffectedSpacesForSkill(skill, unit, space.grid, space.position)){
                    if(affectedSpace.unit != null){
                        var affectedUnit = affectedSpace.unit;

                        switch(skill.type){
                            case "damage":                            
                                var dmg = PlayState.calculateSkillDamage(skill, affectedUnit, unit);

                                if(affectedUnit.hp.value - dmg <= 0){
                                    points += 9999;
                                } else {
                                    points += dmg;
                                }
                            case "healing":
                                var plac_hp:Int = affectedUnit.hp.value;

                                for(i in 0...skill.effects.eff_heal){
                                    plac_hp ++;
                                    points ++;

                                    if(plac_hp >= affectedUnit.maxHp.value){
                                        break;
                                    }
                                }
                            case "debuff" | "buff":
                                for(effect in skill.effects.eff_statuses){
                                    var hasThisEffect:Bool = false;
                                    for(containedeffect in affectedUnit.statuses){
                                        if(containedeffect.id == effect.id){
                                            hasThisEffect = true;
                                            break;
                                        }
                                    }
                                    if(hasThisEffect){
                                        points += 3;
                                    } else {
                                        points += 10;

                                        var statusData = new StatusEffectData(effect.id);

                                        if(skill.type == "debuff"){
                                            points += statusData.effects.eff_damage;
                                        } else if(skill.type == "buff"){
                                            points += statusData.effects.eff_heal;
                                        }
                                    }
                                }
                            default: 
                                //
                        }
                    }
                }

                if(points > highestPoints){
                    advantages.set(skill, space);
                    pointsPerSkill.set(skill, points);
                    highestPoints = points;
                }
            }
        }

        return advantages;
    }

    function getFinalDecision(availableSkills:Array<SkillData>, advantage:Map<SkillData, GridSpace>):UnitAIDecision
    {        
        var range:Int = 0;
        var skillDatas:Array<Array<Dynamic>> = []; // skill data, low, high

        for(skill in availableSkills){
            var mult:Float = 1;

            switch(skill.type){
                case "damage":
                    mult = unit.data.ai_damage;
                case "healing":
                    mult = unit.data.ai_healing;
                case "debuff":
                    mult = unit.data.ai_debuff;
                case "buff":
                    mult = unit.data.ai_buff;
                default:
                    //
            }

            var amount:Int = Std.int(pointsPerSkill.get(skill) * mult);

            skillDatas.push([skill, range, range + amount]);
            
            range += amount;
        }

        var decision:Int = FlxG.random.int(0, range);

        for (skill in skillDatas)
		{
			if (decision >= skill[1] && decision < skill[2])
			{
                var skillAdvantage = advantage.get(skill[0]);

				return({skillData: skill[0], unit: unit, grid: skillAdvantage.grid, position: skillAdvantage.position});
			}
		}

        return({skillData: null, unit: unit, grid: enemyGrid, position: FlxPoint.get(1,1)});
    }
}
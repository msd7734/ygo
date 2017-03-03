-- Reptilianne Lair
function c91580104.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- Reduce ATK
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c91580104.cost)
	--e2:SetCondition(c91580104.spcon)
	e2:SetTarget(c91580104.target)
	e2:SetOperation(c91580104.operation)
	c:RegisterEffect(e2)
	-- Search, Reptilianne to hand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	-- this flag is the secret sauce that prevents it from missing the timing
	-- without the damage step flag, it will not work when destroyed by battle
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c91580104.scon)
	e3:SetTarget(c91580104.starget)
	e3:SetOperation(c91580104.soperation)
	c:RegisterEffect(e3)
	-- Search on Xyz summon
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_SPSUMMON)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(c91580104.xcon)
	e4:SetTarget(c91580104.starget)
	e4:SetOperation(c91580104.soperation)
	c:RegisterEffect(e4)
	
	-- way to make effect work for multiple cases (event types)
	-- local e3=e2:Clone()
	-- e3:SetCode(EVENT_REMOVE)
	-- c:RegisterEffect(e3)
end

function c91580104.scon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c91580104.atkfilter,1,nil)
end


function c91580104.atkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetPreviousAttackOnField()==0
end

function c91580104.rfilter(c)
	local reptilianne=0x3C
	return c:IsSetCard(reptilianne) and c:IsAbleToHand()
end

function c91580104.xcon(e,tp,eg,ep,ev,re,r,rp)
	local xc=eg:GetFirst()
	return xc:GetSummonType()==SUMMON_TYPE_XYZ and xc:GetOverlayGroup():IsExists(c91580104.atkfilter,1,nil)
end

function c91580104.starget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c91580104.rfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function c91580104.soperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c91580104.rfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- important note: condition and cost need to be rolled into one function
-- seems like it's always either one or the other (per effect), not both

function c91580104.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c91580104.rfilter,tp,LOCATION_HAND,0,1,nil)
		and eg:IsExists(c91580104.spfilter,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g1=Duel.SelectMatchingCard(tp,c91580104.rfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g1)
	Duel.ShuffleHand(tp)
end

function c91580104.spfilter(c,tp)
	return c:GetSummonPlayer()~=tp and c:IsFaceup()
end

-- function c91580104.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- -- tp is triggering player
	-- -- you could be 1 or 0, so 1-tp always gets the other player
	-- -- checking on eg (event group). Effect e2 is triggered on a special summon, so eg is the monster(s) special summoned
	-- return eg:IsExists(c91580104.spfilter,1,nil,tp)
-- end

function c91580104.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c91580104.spfilter,1,nil,tp) end
	local g=eg:FilterSelect(tp,c91580104.spfilter,1,1,nil,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end

function c91580104.operation(e,tp,eg,ep,ev,re,r,rp)
	--local g=eg:FilterSelect(tp,c91580104.spfilter,1,1,nil,tp)
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		-- reset when this card leaves the field (?)
		-- RESET_EVENT apparently means: reset when EVENT_* occurs
		-- it seems this next line is boilerplate for any effect that is placed on a card by another card
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
	end
end

-- IsRelateToEffect is used to check whether a card is in the same instance state when it was targeted. For example:
-- 1. Player A activates Compulsory Evacuation Device, targetting Player B's monster.
-- 2. Player B responds by banishing that monster with Interdimensional Matter Transporter.
-- 3. Since the monster is now treated as a new isntance, Compulsory Evacuation Device's IsRelateToEffect will return false, meaning the effect will not be applied.

-- If IsRelateToEffect weren't checked in CED, it would have instead returned the monster from the banished zone into Player B's hand. Prevening this is what IsRelateToEffect is for.

-- IsRelateToBattle is equivalent to (c:IsAttacker() or c:IsAttackTarget()), and as such can only be used during the Battle Phase, while a battle is going on.

-- IsRelateToCard is a more complex function that is used when you manually create and maintain card relationships for delayed effects. See Overmind Archfiend for an example.
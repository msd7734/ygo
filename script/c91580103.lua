-- Reptilianne Awakening
function c91580103.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c91580103.cost)
	e1:SetTarget(c91580103.target)
	e1:SetOperation(c91580103.activate)
	c:RegisterEffect(e1)
	-- Draw on destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c91580103.descon)
	e2:SetTarget(c91580103.drwtarget)
	e2:SetOperation(c91580103.drwop)
	c:RegisterEffect(e2)
end

-- Theory (CONFIRMED):
-- if chk==0, that means it is applying it NOT through activation
-- so, checking if it's possible to target, cost, etc. and thereby activate
-- for example, in a cost function: chk is not 0 when the cost is being paid.
-- chk == 0 when the game wants to know whether it's possible to pay the cost

--Duel.SelectMatchingCard(tp,Card.IsReleasable,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
--Duel.SelectMatchingCard(tp,callback,tp,yourlocation,theirlocation,howmanyofyours,howmanyoftheirs,nil,cbackparams...)

function c91580103.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local avail=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local ct=-avail+1
		if ct>1 then return false end
		if ct>0 and not Duel.IsExistingMatchingCard(c91580103.cfilter,tp,LOCATION_MZONE,0,1,nil,e) then return false end
		return Duel.IsExistingMatchingCard(c91580103.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local g=Duel.SelectMatchingCard(tp,c91580103.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e)
		Duel.Release(g,REASON_COST)
	else
		local g=Duel.SelectMatchingCard(tp,c91580103.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
		Duel.Release(g,REASON_COST)
	end
end

function c91580103.cfilter(c,e)
	return c:IsFaceup() and c:GetAttack()==0 and not c:IsImmuneToEffect(e) and c:IsReleasable()
end

function c91580103.spfilter(c,e,tp)
	local reptilianne=0x3C
	return c:IsSetCard(reptilianne) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c91580103.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(c91580103.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function c91580103.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c91580103.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

function c91580103.descon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)~=0 and rp~=tp
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end

function c91580103.drwtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function c91580103.drwop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end


-- Reptilianne Cobriss
function c91580106.initial_effect(c)
	-- Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(c91580106.condition)
	e1:SetTarget(c91580106.target)
	e1:SetOperation(c91580106.operation)
	e1:SetCountLimit(1,91580106)
	c:RegisterEffect(e1)
end

function c91580106.nonzerofilter(c,tp)
	return c:GetControler()~=tp and c:IsType(TYPE_MONSTER) and c:GetAttack()>0 and c:IsFaceup()
end

function c91580106.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(c91580106.nonzerofilter,tp,0,LOCATION_MZONE,nil,tp)==0
end

function c91580106.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function c91580106.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and c:IsLocation(LOCATION_HAND) then
		Duel.SendtoGrave(c,REASON_RULE)
	end
end
-- Reptilianne Bantu
function c91580107.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon from hand
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c91580107.spcon)
	e1:SetOperation(c91580107.spop)
	c:RegisterEffect(e1)
	--banish instead of sending to grave
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	--reduce atk on banish
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetTarget(c91580107.btg)
	e3:SetOperation(c91580107.bop)
	c:RegisterEffect(e3)
end

function c91580107.spfilter(c,tp)
	return c:GetControler()~=tp and c:IsFaceup()
end

function c91580107.gfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsSetCard(0x3C) and not c:IsCode(91580107)
	--return c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_REPTILE)
end

function c91580107.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(c91580107.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
		and Duel.IsExistingMatchingCard(c91580107.gfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

function c91580107.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectMatchingCard(tp,c91580107.spfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
	local tc=g:GetFirst()
	if tc:IsFaceup() and tc:IsOnField() then
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-600)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
	end
end

function c91580107.btg(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.IsExistingMatchingCard(c91580107.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end

function c91580107.bop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectMatchingCard(tp,c91580107.spfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
	local tc=g:GetFirst()
	if tc:IsFaceup() and tc:IsOnField() then
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1500)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
	end
end
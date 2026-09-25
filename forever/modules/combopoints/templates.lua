BBP_ForeverRogueComboPointMixin = {}

function BBP_ForeverRogueComboPointMixin:Setup()
    self.isFull = nil
    self.isCharged = nil
    self:ResetVisuals()
    self:Show()
end

function BBP_ForeverRogueComboPointMixin:Update(isFull, isCharged)
    if self.isFull == isFull and self.isCharged == isCharged then
        return
    end

    local wasFull = self.isFull ~= nil and self.isFull or false
    local wasCharged = self.isCharged ~= nil and self.isCharged or false
    self.isFull = isFull
    self.isCharged = isCharged

    self:ResetVisuals()

    local transitionAnim = BBP_ForeverRogueComboPointTransitions.GetTransitionAnim(wasCharged, wasFull, isCharged, isFull)
    if transitionAnim then
        self[transitionAnim]:Restart()
    end
end

function BBP_ForeverRogueComboPointMixin:ResetVisuals()
    for _, transitionAnim in ipairs(self.transitionAnims) do
        transitionAnim:Stop()
    end

    for _, fxTexture in ipairs(self.fxTextures) do
        fxTexture:SetAlpha(0)
    end
end

BBP_ForeverRogueComboPointTransitions = {}

function BBP_ForeverRogueComboPointTransitions.Init()
    local uncharged, charged = false, true
    local empty, full = false, true
    BBP_ForeverRogueComboPointTransitions.transitions = {
        { from = {uncharged, empty}, to = {uncharged, empty}, anim = "unchargedEmpty" },

        { from = {uncharged, empty}, to = {uncharged, full}, anim = "unchargedEmptyToUnchargedFull" },
        { from = {uncharged, empty}, to = {charged, full}, anim = "unchargedEmptyToChargedFull" },
        { from = {uncharged, empty}, to = {charged, empty}, anim = "unchargedEmptyToChargedEmpty" },

        { from = {charged, empty}, to = {charged, full}, anim = "chargedEmptyToChargedFull" },
        { from = {charged, empty}, to = {uncharged, full}, anim = "chargedEmptyToUnchargedFull" },
        { from = {charged, empty}, to = {uncharged, empty}, anim = "chargedEmptyToUnchargedEmpty" },

        { from = {uncharged, full}, to = {uncharged, empty}, anim = "unchargedFullToUnchargedEmpty" },
        { from = {uncharged, full}, to = {charged, full}, anim = "unchargedFullToChargedFull" },
        { from = {uncharged, full}, to = {charged, empty}, anim = "unchargedFullToChargedEmpty" },

        { from = {charged, full}, to = {charged, empty}, anim = "chargedFullToChargedEmpty" },
        { from = {charged, full}, to = {uncharged, empty}, anim = "chargedFullToUnchargedEmpty" },
        { from = {charged, full}, to = {uncharged, full}, anim = "chargedFullToUnchargedFull" },
    }
end

function BBP_ForeverRogueComboPointTransitions.GetTransitionAnim(fromIsCharged, fromIsFull, toIsCharged, toIsFull)
    if not BBP_ForeverRogueComboPointTransitions.transitions then
        BBP_ForeverRogueComboPointTransitions.Init()
    end

    for _, transition in ipairs(BBP_ForeverRogueComboPointTransitions.transitions) do
        local from, to = transition.from, transition.to
        if from[1] == fromIsCharged and from[2] == fromIsFull and to[1] == toIsCharged and to[2] == toIsFull then
            return transition.anim
        end
    end
    return nil
end

BBP_ForeverDruidComboPointMixin = {}

function BBP_ForeverDruidComboPointMixin:Setup()
    self.isActive = nil
    self:ResetVisuals()
    self:Show()
end

function BBP_ForeverDruidComboPointMixin:SetActive(isActive)
    if self.isActive == isActive then
        return
    end

    self.isActive = isActive

    self:ResetVisuals()

    if self.isActive then
        self.FB_Slash:Show()
        self.activateAnim:Restart()
    else
        self.deactivateAnim:Restart()
    end
end

function BBP_ForeverDruidComboPointMixin:ResetVisuals()
    self.activateAnim:Stop()
    self.deactivateAnim:Stop()

    self.FB_Slash:Hide()

    for _, fxTexture in ipairs(self.fxTextures) do
        fxTexture:SetAlpha(0)
    end
end

-- Get a redemption code by its code string
GetRedeemCode = function(code)
    local result = MySQL.query.await('SELECT * FROM kp_redeem_codes WHERE code = ? AND is_deleted = 0', {code})
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

-- Get all rewards for a specific code
GetCodeRewards = function(codeId)
    local result = MySQL.query.await('SELECT * FROM kp_redeem_rewards WHERE code_id = ?', {codeId})
    if result and #result > 0 then
        return result
    end
    return {}
end

-- Check if a user has already redeemed a specific code
HasUserRedeemedCode = function(identifier, codeId)
    local result = MySQL.query.await('SELECT COUNT(*) as count FROM kp_redeem_history WHERE code_id = ? AND user_identifier = ?', {codeId, identifier})
    return result[1].count > 0
end

-- Record a code redemption
RecordRedemption = function(identifier, codeId)
    MySQL.insert('INSERT INTO kp_redeem_history (code_id, user_identifier) VALUES (?, ?)', {codeId, identifier})
    MySQL.update('UPDATE kp_redeem_codes SET usage_count = usage_count + 1 WHERE id = ?', {codeId})
end

-- Create a new redemption code
CreateRedeemCode = function(code, creator, description, usageLimit)
    local result = MySQL.insert.await('INSERT INTO kp_redeem_codes (code, creator, description, usage_limit) VALUES (?, ?, ?, ?)', 
        {code, creator, description, usageLimit})
    return result
end

-- Add a reward to a redemption code
AddReward = function(codeId, rewardType, subtype, name, amount, plate)
    MySQL.insert('INSERT INTO kp_redeem_rewards (code_id, type, subtype, name, amount, plate) VALUES (?, ?, ?, ?, ?, ?)', 
        {codeId, rewardType, subtype, name, amount, plate})
end

-- Delete a redemption code (soft delete)
DeleteRedeemCode = function(code, deletedBy, deleteReason)
    MySQL.update('UPDATE kp_redeem_codes SET is_deleted = 1, deleted_by = ?, delete_reason = ?, deleted_at = CURRENT_TIMESTAMP WHERE code = ?', 
        {deletedBy, deleteReason, code})
end

-- Get all active redemption codes
GetAllActiveCodes = function()
    local result = MySQL.query.await('SELECT * FROM kp_redeem_codes WHERE is_deleted = 0')
    if result and #result > 0 then
        return result
    end
    return {}
end

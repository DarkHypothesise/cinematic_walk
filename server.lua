-- Print to console when the resource starts
print("^2Cinematic Walk^7: Resource started")

-- Register command on the server side
RegisterCommand("cinewalk", function(source, args, rawCommand)
    -- You can add permission checks here if needed
    -- Or broadcast it was used by a specific player
    -- For now just let the client handle it
end, false)

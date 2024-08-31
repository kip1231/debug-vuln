local totalTests = 0
local passedTests = 0
local failedTests = 0
local executorName = identifyexecutor() or "Shit"
local function test(testName, func)
    local success, err = pcall(func)
    totalTests = totalTests + 1
    if not success then
        failedTests = failedTests + 1
        warn("❌ " .. testName .. " failed: " .. err)
    else
        passedTests = passedTests + 1
        print("✅ " .. testName .. " passed")
    end
end




if debug.getstack then
    print("🔍 testing debug.getstack...")

    test("getstack one-based check", function()
        local success = pcall(function() debug.getstack(1, 0) end)
        if success then
            error("getstack must be one based")
        end
    end)

    test("getstack negative numbers check", function()
        local success = pcall(function() debug.getstack(1, -1) end)
        if success then
            error("getstack must not allow negative numbers")
        end
    end)

    test("getstack bounds check", function()
        local success = pcall(function() 
            local size = #debug.getstack(1)
            debug.getstack(1, size + 1) 
        end)
        if success then
            error("getstack must check bounds (use L->ci->top)")
        end
    end)

    test("getstack C functions check", function()
        if newcclosure then
            local success = pcall(function() 
                newcclosure(function() debug.getstack(2, 1) end)() 
            end)
            if success then
                error("getstack must not allow reading the stack from C functions")
            end
        end
    end)
else
    print("⚠️ debug.getstack not found, skipping checks.")
end

if debug.setstack then
    print("🔍 testing debug.setstack...")

    test("setstack one-based check", function()
        local success = pcall(function() debug.setstack(1, 0, nil) end)
        if success then
            error("setstack must be one based")
        end
    end)

    test("setstack negative numbers check", function()
        local success = pcall(function() debug.setstack(1, -1, nil) end)
        if success then
            error("setstack must not allow negative numbers")
        end
    end)

    test("setstack bounds check", function()
        local success = pcall(function() 
            local size = #debug.getstack(1)
            debug.setstack(1, size + 1, "") 
        end)
        if success then
            error("setstack must check bounds (use L->ci->top)")
        end
    end)

    test("setstack C functions check", function()
        if newcclosure then
            local success = pcall(function() 
                newcclosure(function() debug.setstack(2, 1, nil) end)() 
            end)
            if success then
                error("setstack must not allow C functions to have stack values set")
            end
        end
    end)

    test("setstack type check", function()
        local success = pcall(function() 
            local a = 1 
            debug.setstack(1, 1, true) 
            print(a) 
        end)
        if success then
            error("setstack must check if the target type is the same (block writing stack if the source type does not match the target type)")
        end
    end)
else
    print("⚠️ debug.setstack not found, skipping checks.")
end

if debug.getupvalues and debug.getupvalue and debug.setupvalue then
    print("🔍 testing debug.getupvalue(s)/setupvalue...")

    local upvalue = 1
    local function x()
        print(upvalue)
        upvalue = 124
    end

    test("getupvalues negative numbers check", function()
        local success = pcall(function() debug.getupvalues(-1) end)
        if success then
            error("getupvalues must not allow negative numbers")
        end
    end)

    test("getupvalue negative numbers check", function()
        local success = pcall(function() debug.getupvalue(-1, 1) end)
        if success then
            error("getupvalue must not allow negative numbers")
        end
    end)

    test("getupvalue bounds check", function()
        local success = pcall(function() debug.getupvalue(x, 2) end)
        if success then
            error("getupvalue must check upvalue bounds (use cl->nupvals)")
        end
    end)

    test("setupvalue negative numbers check", function()
        local success = pcall(function() debug.setupvalue(x, -1, nil) end)
        if success then
            error("setupvalue must not allow negative numbers")
        end
    end)

    test("setupvalue bounds check", function()
        local success = pcall(function() debug.setupvalue(x, 2, nil) end)
        if success then
            error("setupvalue must check upvalue bounds (use cl->nupvals)")
        end
    end)

    test("setupvalue C functions check", function()
        local success = pcall(function() debug.setupvalue(game.GetChildren, 1, nil) end)
        if success then
            error("setupvalue must not allow C functions to have upvalues set")
        end
    end)
else
    print("⚠️ debug.getupvalue(s)/setupvalue not found, skipping checks.")
end

if debug.getprotos then
    print("🔍 testing debug.getprotos...")

    local function a()
        local function b()
            return 123
        end

        b()
    end

    test("getprotos negative numbers check", function()
        local success = pcall(function() debug.getprotos(-1) end)
        if success then
            error("getprotos must not allow negative numbers")
        end
    end)

    test("getprotos C functions check", function()
        local success = pcall(function() debug.getprotos(coroutine.wrap(function() end)) end)
        if success then
            error("getprotos must not allow C functions to have protos grabbed (they don't have any)")
        end
    end)

    test("getprotos prototypes count check", function()
        local protos = debug.getprotos(a)
        if #protos ~= 1 then
            error("debug.getprotos is returning an invalid amount of prototypes")
        end
    end)

    test("getprotos call function check", function()
        local protos = debug.getprotos(a)
        local success, result = pcall(function() return protos[1]() end)
        if success and result == 123 then
            error("debug.getprotos allows calling the resulting function")
        end
    end)
else
    print("⚠️ debug.getprotos not found, skipping checks.")
end

if debug.getproto then
    print("🔍 testing debug.getproto...")

    local function a()
        local function b()
            return 123
        end

        b()
    end

    test("getproto negative numbers check", function()
        local success = pcall(function() debug.getproto(-1, 1) end)
        if success then
            error("getproto must not allow negative numbers")
        end
    end)

    test("getproto C functions check", function()
        local success = pcall(function() debug.getproto(coroutine.wrap(function() end), 1) end)
        if success then
            error("getproto must not allow C functions to have protos grabbed (they don't have any)")
        end
    end)

    test("getproto call function check", function()
        local proto = debug.getproto(a, 1)
        local success, result = pcall(function() return proto() end)
        if success and result == 123 then
            error("debug.getproto allows calling the resulting function")
        end
    end)
else
    print("⚠️ debug.getproto not found, skipping checks.")
end

if debug.setproto then
    warn("❌ debug.setproto is fundamentally flawed, remove this function.")
end

if debug.getconstants and debug.getconstant and debug.setconstant then
    print("🔍 testing debug.getconstant(s)/setconstant...")

    local function x()
        print("a")
    end

    test("getconstants negative numbers check", function()
        local success = pcall(function() debug.getconstants(-1) end)
        if success then
            error("getconstants must not allow negative numbers")
        end
    end)

    test("getconstant negative numbers check", function()
        local success = pcall(function() debug.getconstant(-1, 1) end)
        if success then
            error("getconstant must not allow negative numbers")
        end
    end)

    test("getconstant bounds check", function()
        local success = pcall(function() 
            local size = #debug.getconstants(x)
            debug.getconstant(x, size + 1) 
        end)
        if success then
            error("getconstant must check constant bounds (use P->sizek)")
        end
    end)

    test("setconstant negative numbers check", function()
        local success = pcall(function() debug.setconstant(x, -1, nil) end)
        if success then
            error("setconstant must not allow negative numbers")
        end
    end)

    test("setconstant bounds check", function()
        local success = pcall(function() 
            local size = #debug.getconstants(x)
            debug.setconstant(x, size + 1, nil) 
        end)
        if success then
            error("setconstant must check constant bounds (use P->sizek)")
        end
    end)

    test("setconstant C functions check", function()
        local success = pcall(function() debug.setupvalue(game.GetChildren, 1, nil) end)
        if success then
            error("setupvalue must not allow C functions to have upvalues set")
        end
    end)
else
    print("⚠️ debug.getconstant(s)/setconstant not found, skipping checks.")
end

local successRate = (passedTests / totalTests) * 100
print(string.format("📊 Test Results: %d passed, %d failed, %.2f%% success rate", passedTests, failedTests, successRate))
print("📝 The test is done on: " .. tostring(executorName))

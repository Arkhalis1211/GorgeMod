local function MakeAssetLoader(name, assets)
    local function fn()
        return CreateEntity()
    end

    return Prefab(name, fn, assets)
end

return MakeAssetLoader
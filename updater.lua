local Updater = class('Updater')

local am = {}
function Updater:init()
    -- local storagePath  = cc.FileUtils:getInstance():getWritablePath() 

    -- local manifestPath = "manifests/project.mainfest"
    -- am = cc.AssetsManagerEx:create(manifestPath, storagePath ..'update' )
    -- --am:update()
    -- am:retain()
end 
-- 检查远程是否需要更新，需要更新返回true
function Updater:checkUpdate()
    --print('//////////////////////',am:getLocalManifest():isLoaded() )
    --return not am:getLocalManifest():isLoaded()
    return true  
end 
--如何存在数字压缩包，删除当前文件夹下文件
function Updater:checkFile(storagePath)
    -- body
    for i=100,1000,1 do 
        local fileName = storagePath .. i .. ".zip"
        local isFileExist = cc.FileUtils:getInstance():isFileExist(fileName)
        if isFileExist then 
            return true 
        end 
    end 
end

-- function Updater:changeLogin(update_scene)
--     -- local scene = display.getRunningScene() 
--     -- update_scene:changeLogin()
-- end 

function Updater:update(update_scene)

    update_scene:changeUpdate()

    local storagePath  = cc.FileUtils:getInstance():getWritablePath() .. 'update'

    --如何存在数字压缩包，删除当前文件夹下文件
    -- if self:checkFile(storagePath) then 
    --     cc.FileUtils:getInstance():removeDirectory(storagePath)
    -- end 

    local manifestPath ="update/project.manifest"
    print('.........',manifestPath,storagePath)
    am = cc.AssetsManagerEx:create(manifestPath, storagePath )
    am:retain()
    if not am:getLocalManifest():isLoaded() then
        print("Fail to update assets, step skipped.???????????1")
    else    

        print('start update1')
        local function onUpdateEvent(event)
            local state = am:getState()

            print('am:state',state)
            local eventCode = event:getEventCode()
            print("am:eventCode",eventCode)
            if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then
                print("No local manifest file found, skip assets update.")
                update_scene:changeLogin()
            elseif  eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then

                local assetId = event:getAssetId()
                local percent = event:getPercent()
                local strInfo = ""

                print('..............',assetId,cc.AssetsManagerExStatic.VERSION_ID,cc.AssetsManagerExStatic.MANIFEST_ID )
                if assetId == cc.AssetsManagerExStatic.VERSION_ID then
                    strInfo = string.format("Version file: %d%%", percent)
                    update_scene:updatePercent("检查更新版本:",percent)
                elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then
                    strInfo = string.format("检查更新目录:", percent)
                else
                    strInfo = string.format("%d%%", percent)
                    if update_scene then 
                        update_scene:updatePercent("更新资源中:",percent)
                    end 
                end
                print(strInfo)
   
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST or 
                   eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST then
                print("Fail to download manifest file, update skipped.")
                update_scene:updatePercent("下载失败，跳过更新")
                
                update_scene:changeLogin()
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE then 
                print("ALREADY_UP_TO_DATE.")

                update_scene:updatePercent("已经是最新版本")
                update_scene:changeLogin()
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
                print("Update finished.")
                update_scene:updatePercent("更新完成")
                update_scene:changeLogin()
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
                print("Asset " .. event:getAssetId() .. ", " .. event:getMessage())
                
                update_scene:updatePercent("下载失败，跳过更新")
            end
        end

        local listener = cc.EventListenerAssetsManagerEx:create(am,onUpdateEvent)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

        am:update()

    end 
end 

return Updater

--Comment
--like this
--
--This Game is developed by:
------------------------------------------------
--Mutavhatsindi Ipfani
--
--Year 2023 (Self Learning)
--
------------------------------------------------
--Background Images were downloaded from internet
--
--

require("conf")

math = require 'math'

local gameState = 0

local lastSpawnTime = 0

local  player = {
    x = (love.graphics.getWidth()/2 ),
    y = (love.graphics.getHeight()/2),
    velocity = 100,
    Rotation = 0,
    Score = 0,
    life = 100,
    isMoving = false,
    sprite = love.graphics.newImage('/sprites/player.png'),
    tankSound = love.audio.newSource("/sound/smartsound_TRANSPORTATION_TANK_Small_Tracks_Rattle_Slow_01.mp3", "static")

}

--New Bullet
local bullet ={
    x = player.x + player.sprite:getWidth()/2,
    y = player.y + player.sprite:getHeight()/2,
    vx = 0,
    vy = 0,
    speed = 500,
}

--moving text on menu
--It will be moving around
change = -1
changey = 0

local enemies = {}

function newEnemy(image)
  local enemy = {}
  enemy.x = math.random(0, love.graphics:getWidth(window) - image:getWidth())
  enemy.y = math.random(0, love.graphics:getHeight(window) - image:getHeight())
  enemy.width = love.graphics.getWidth(image)
  enemy.height = love.graphics.getHeight(image)
  enemy.removed = false
  enemy.sprite = image
  enemy.velocity = 20
  enemy.isMoving = true
  enemy.life = 100
  enemy.tankSound = love.audio.newSource("/sound/smartsound_TRANSPORTATION_TANK_Small_Tracks_Rattle_Slow_01.mp3", "static")
  enemy.Rotation = math.atan2(((player.y + player.sprite:getWidth()/2 ) - enemy.y), (player.x + player.sprite:getHeight()/2) - enemy.x)
  enemy.distance = math.sqrt((enemy.y - player.y)^2.0 + (enemy.x - player.x)^2.0)
  table.insert(enemies, enemy)
end

function generateEmemies(me)
    newEnemy(me)
end

function checkCollision(sprite1, sprite2)
    aw, ah = sprite1.sprite:getDimensions()
    bw, bh = sprite2.sprite:getDimensions()

    return sprite1.x < (sprite2.x + bw) and
    sprite2.x < (sprite1.x + aw) and
    sprite1.y < (sprite2.y + bh) and
    sprite2.y < (sprite1.y + ah)
end

function love.load()
   
    animator = require 'libraries/anim8'
    fontDragon = love.graphics.newFont('/Font/DragonHunter-9Ynxj.otf', 80)
    fontSpace = love.graphics.newFont('/Font/SpaceMission-rgyw9.otf', 10)
    fontSofaChronme = love.graphics.newFont('/font/sofachrome rg.otf', 12)
    fontDefault = love.graphics.getFont()

    strContinue = "PRESS ENTER TO CONTINUE"
    contW = love.graphics.getFont():getWidth(strContinue)
    contH = love.graphics.getFont():getHeight(strContinue)
    contPosx =  love.graphics.getWidth()/2 - contW/2
    contPosy = love.graphics.getHeight()/2 - contH/2
    
    groups = {}

    maximumEnemies = 2 --Two enemies at a time
    activeEnemies = 0
    
    backGroundMusic = love.audio.newSource("/sound/mixkit-drone-terror-ambience-2749.wav", "static")
    backGroundTank = love.audio.newSource("/sound/zapsplat_warfare_tank_matilda_mrk_2_1939_start_up_engine_rev_idle_int_hanger_onboard_ext_pers_25203.mp3", "static")
    drumsMusic = love.audio.newSource("/sound/mixkit-drums-of-war-2784.wav", "static")

    myEnemy = love.graphics.newImage('/sprites/enemy.png')
    background = love.graphics.newImage('/sprites/outdoors-cobblestone-texture.jpg')
    menuBackground = love.graphics.newImage('/sprites/background.png')
    
    groups.largeExplosion = love.graphics.newImage('/sprites/bigexplosive.png')
    groups.largeExplosionGrid = animator.newGrid(256,256,groups.largeExplosion:getWidth(), groups.largeExplosion:getHeight())

    groups.animation = {}
    groups.animation.explode = animator.newAnimation(groups.largeExplosionGrid('1-8', '1-6'), 0.1)
    -- explosions.animation.explode = animator.newAnimation(explosions.largeExplosionGrid('1-8', '1-3','1-8','4-6'), 0.1)
    --Column 1 rown 2 (1, 2)

end

function love.update(dt)

    --New Bullet
    --Update Bullet
    bullet.x = bullet.x + bullet.vx*dt;
    bullet.y = bullet.y + bullet.vy*dt;
    if love.keyboard.isDown('space') then
        --New Bullet
        bullet.x = player.x + 10 * math.cos(player.Rotation)
        bullet.y = player.y + 10 * math.sin(player.Rotation)
        bullet.vx = bullet.speed * math.cos(player.Rotation)
        bullet.vy = bullet.speed * math.sin(player.Rotation)
    end

    --Shift around Press Enter to continue
    if gameState == 0 then
        if (contPosx > love.graphics.getWidth() - contW) and change > 0 then
            change = -1
            changey = math.random(-1,1)
        end
        if (contPosx < 0) and change < 0 then
            change = 1
            changey = math.random(-1,1)
        end
        if (contPosy > love.graphics.getHeight() - contH) and changey > 0 then
            changey = -1
        end
        if (contPosy < 0) and changey < 0 then
            changey = math.random(0,1)
        end

        contPosx = contPosx + change
        contPosy = contPosy + changey
        --contPosy = contPosy + 1
    end

    mousex, mousey = love.mouse.getPosition()

    if love.keyboard.isDown('escape') then
        love.event.quit()
    end

    if love.keyboard.isDown("up") then
        player.x = player.x + math.cos(player.Rotation)*player.velocity*dt
        player.y = player.y + math.sin(player.Rotation)*player.velocity*dt
    end
    if love.keyboard.isDown('down') then
        player.x = player.x - math.cos(player.Rotation)*player.velocity*dt
        player.y = player.y - math.sin(player.Rotation)*player.velocity*dt
    end
    --Player tank moving sound
    if not player.isMoving then
        love.audio.stop(player.tankSound)
    else
        love.audio.play(player.tankSound)
    end

    --Rotating with the arrowkeys
    if (love.keyboard.isDown('up') and love.keyboard.isDown('right')) 
    or (love.keyboard.isDown('down') and love.keyboard.isDown('right')) then
        player.Rotation = player.Rotation + dt
    end
    if (love.keyboard.isDown('down') and love.keyboard.isDown('left'))
    or (love.keyboard.isDown('up') and love.keyboard.isDown('left')) then
        player.Rotation = player.Rotation - dt
    end    
    
    if player.x >= love.graphics.getWidth() then
        player.x = love.graphics.getWidth() - player.sprite:getWidth()
    end
    if player.x <= 0 then
        player.x = player.sprite:getWidth()
    end
    if player.y >= love.graphics.getHeight() then
        player.y = love.graphics.getHeight() - player.sprite:getHeight()
    end
    if player.y <= 0 then
        player.y = player.sprite:getHeight()
    end

    groups.animation.explode:update(dt)

    if activeEnemies < maximumEnemies then
        lastSpawnTime = lastSpawnTime + dt
    end
--Check Enemies colliding
    for x =#enemies, 1, -1 do
        local enemy1 = enemies[x]
        for y = (x-1), 1, -1 do
            local enemy2 = enemies[y]
             if checkCollision(enemy1, enemy2) then
                --Jump the coordinates
                 enemy2.x = enemy2.x - 50
                enemy2.y = enemy2.y - 50
            end
        end
    end

    for i=#enemies, 1, -1 do
        local enemy = enemies[i]
        if not enemy.removed then
            enemy.Rotation = math.atan2((enemy.y - (player.y )), (enemy.x - player.x))
            enemy.distance = math.sqrt((enemy.y - (player.y ))^2.0 + (enemy.x - player.x)^2.0)

            if checkCollision(player, enemy) then
                --enemy.removed = true --For testing
                --Reduce life of the sprites that collided
               -- player.life = player.life - 5
                enemy.life = enemy.life - 10

                enemy.x = enemy.x - 30
                enemy.y = enemy.y - 30
             end

             if enemy.life < 0 then
                enemy.removed = true
                activeEnemies = activeEnemies - 1 --Kiling Enemy
                love.audio.stop(enemy.tankSound)
             end
        
            if enemy.distance > 300 then
                --Lets chase him
                love.audio.play(enemy.tankSound)
                enemy.isMoving = true
                enemy.x = enemy.x - math.cos(enemy.Rotation)*enemy.velocity*dt
                enemy.y = enemy.y - math.sin(enemy.Rotation)*enemy.velocity*dt
            else
                isMoving = false
                love.audio.pause(enemy.tankSound)
            end

        else table.remove(enemies, i)
            player.Score = player.Score + 5
        end
    end
end


function love.draw()

    
    --STATE 0 MENU OPTIONS
    if gameState == 0 then
        --MainMenu
        love.graphics.draw(menuBackground)

        --Writting
        love.graphics.setFont(fontDragon)
        stringGameName = "TANK BATTLES"
        gNameW =  love.graphics.getFont():getWidth(stringGameName)
        gNameH=  love.graphics.getFont():getHeight(stringGameName)

        love.graphics.print(stringGameName, love.graphics.getWidth()*1/2 - gNameW/2, (gNameH)*1/4)

        love.graphics.setFont(fontSofaChronme)
        strDev = "DEVELOPER\nMutavhatsindi   Ipfani"
        devW = love.graphics.getFont():getWidth(strDev)
        devH = love.graphics.getFont():getHeight(strDev)

        love.graphics.print(strDev, love.graphics.getWidth() - devW - 5, love.graphics.getHeight() - devH*3)
        love.graphics.setFont(fontDefault)
        love.graphics.print(strContinue,contPosx, contPosy)

        --Play music
        love.audio.play(backGroundTank)

        if (love.keyboard.isDown 'return') then
            gameState = 1
        end
    end

    --STATE 1 PLAY GAME
    if gameState == 1 then

        love.audio.stop(backGroundTank) --Stop background music
        love.audio.play(drumsMusic) --Play Drums

        love.graphics.draw(background)

        --Make fire explossion
        groups.animation.explode:draw(groups.largeExplosion, (0), 0)

        love.graphics.draw(player.sprite, player.x, player.y, player.Rotation, 1, 1,  player.sprite:getWidth()/2,  player.sprite:getHeight()/2)
        --Player score
        --Player life
        love.graphics.rectangle('fill', 0, 15, player.life, 20)
        love.graphics.print("Player life", 0, 0)
        love.graphics.print("SCORE: "..player.Score, 105, 15)

        if lastSpawnTime > 5  and activeEnemies < 5 and player.life > 0 then 
            generateEmemies(myEnemy)
            lastSpawnTime = 0;
            activeEnemies = activeEnemies + 1
        end

        for i=#enemies, 1, -1 do
            local enemy = enemies[i]
            love.graphics.draw(enemy.sprite, enemy.x, enemy.y, enemy.Rotation, 1, 1, enemy.sprite:getWidth()/2,  enemy.sprite:getHeight()/2 )
            love.graphics.rectangle('fill', 0, 50*i, enemy.life, 20)
            love.graphics.print("Enemy life", 0, 50*i + 30)
        end

    --New Bullet
		love.graphics.circle("fill",bullet.x, bullet.y, 5)

    end
    
    --STATE2 GAME OVER
    if gameState == 2 then
    end
end

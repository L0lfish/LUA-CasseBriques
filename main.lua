-- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf('no')

-- VARIABLES ###################################################################################################################################################


-- On crée l'objet raquette
local pad = {}
pad.x = 0
pad.y = 0
pad.height = 10
pad.length = 30

-- On crée l'objet balle
local ball = {}
ball.x = 0
ball.y = 0
ball.radius = 10
ball.isStuckOnPad = false -- Si la balle est collée ou non à la raquette
ball.xspeed = 0
ball.yspeed = 0

-- Une brique
local brick = {}
local stage = {}  
-- Nombre de vies du joueur
life =3
-- Score du joueur 
score = 0

-- Cette ligne permet de déboguer pas à pas dans ZeroBraneStudio
if arg[#arg] == "-debug" then require("mobdebug").start() end

-- FONCTIONS PERSO ###############################################################################################################################################

function initializeGame ()
  ball.isStuckOnPad = true
  life = 3
  score = 0
  
  -- On va créer la grille de briques et la remplir
  local line,column
  stage = {}
  for line = 1, 6 do
    stage[line] = {} 
    for column = 1, 15 do
      stage[line][column]=1
    end
  end
  
  
end
-- GESTION DE LA COLLISION AVEC LES MURS
function checkWallCollision()
   
   -- Lorsque la balle collisionne avec un mur on inverse sa vélocité x ou y selon le mur en question et on la repositionne pour s'assurer qu'elle ne déborde pas.
   -- Bord droit de l'écran
  if (ball.x+ball.radius) > SCREEN_WIDTH then
    ball.xspeed = 0-ball.xspeed
    ball.x = SCREEN_WIDTH - ball.radius
  end  
  -- Bord gauche de l'écran
  if (ball.x-ball.radius) < 0 then
    ball.xspeed = 0-ball.xspeed
    ball.x = 0+ball.radius
  end
  
  -- Bord haut de l'écran
  if (ball.y-ball.radius) < 0 then
    ball.yspeed = 0-ball.yspeed
    ball.y = 0+ball.radius
  end
  
  -- Si la balle est tombée on la recolle à la raquette et on retire une vie s'il reste des vies sinon la partie est finie
  if ball.y-ball.radius > SCREEN_HEIGHT then
    if life > 0 then
    ball.isStuckOnPad = true
    life = life-1
else
  gameOver(score)
end
end
end  
-- GESTION DE LA COLLISION AVEC LA RAQUETTE
function checkPadCollision()
-- Point de collision
local collisionPad = pad.y - pad.height/2 - ball.radius
  -- S'il y a collision on reverse la velocité y
  if ball.y>=collisionPad and ball.x>(pad.x-pad.length/2) and ball.x<pad.x+pad.length/2 then
    -- on repositionne la balle correctement pour éviter un bug
    ball.y = collisionPad
    ball.yspeed = 0 - ball.yspeed
  end 
  end
-- CHANGEMENT DE DIRECTION DE LA BALLE SELON LA COLLISION
function ballDirection ()
 
  end
-- GESTION DE LA COLLISION AVEC LES BRIQUES
function checkBricksCollision()
  local line = math.floor(ball.y/brick.height) + 1
  local column = math.floor(ball.x/brick.length)+1
  
  if line>=1 and line <= #stage and column >=1 and column<= 15 then
  if stage[line][column] == 1 then
    stage[line][column] = 0
    score = score +1
    ball.yspeed = 0 - ball.yspeed
  end  
  end
  end
-- GESTION DU GAME OVER
function gameOver(score)
  print ("GameOver")
  print ("Votre score :")
  print (score)
  end


-- PROCESSUS JEU ################################################################################################################################################

-- CHARGEMENT DU JEU 
function love.load()
  
  -- contient les dimensions de l'écran pour pouvoir récupérer la taille sans retaper les fonctions à chaque fois
  SCREEN_WIDTH = love.graphics.getWidth()
  SCREEN_HEIGHT = love.graphics.getHeight()  
  
  -- On fixe la raquette verticalement : 
  pad.y = SCREEN_HEIGHT - (pad.height*2)
  
  -- On définit la taille des bricks : 
  brick.height = 15
  brick.length = SCREEN_WIDTH/15
  
  -- On initialise la partie
  initializeGame()  
  
end

-- RAFRAICHISSEMENT DONNEES 
-- Cette fonction met à jour les variables 60*/secondes pour qu'ensuite la fonction love.draw redessine l'écran avec ces paramètres.
-- C'est là-dedans que se gèrent les process du jeu

function love.update(dt)
  
  
  -- La position horizontale de la raquette dépend de la position de la souris
  pad.x = love.mouse.getX()

  -- Si la balle est collée à la raquette (situation de départ avant que le joueur ait cliqué) alors sa position suit la raquette.
  if ball.isStuckOnPad  == true then
    ball.x = pad. x
    ball.y = pad.y - (pad.height/2) - ball.radius
    
    -- Si la balle n'est pas collée alors elle avance en suivant sa trajectoire.
 else 
   ball.x = ball.x + (ball.xspeed*dt)
   ball.y = ball.y + (ball.yspeed*dt)
 end
 checkBricksCollision()
 checkWallCollision()
 checkPadCollision()

end


--RAFRAICHISSEMENT ECRAN
-- Cette fonction redessine l'écran 60*/seconde.
function love.draw()
    -- La raquette
    love.graphics.rectangle("fill", pad.x - (pad.length/2), pad.y - (pad.height/2), pad.length, pad.height)
    
    -- La balle     
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)
    
    -- Les briques
  local line, column
  local bx, by = 0,0
  for line = 1,6 do 
    bx = 0
    for column = 1,15 do
      if stage[line][column] == 1 then
        love.graphics.rectangle("fill", bx+1, by+1, brick.length-2, brick.height-2)
       end   
     bx = bx + brick.length
  end
    by = by+ brick.height
  end
  end
-- EVENT LISTENERS ###############################################################################################################################################
-- SOURIS CLIQUEE
--  Cette fonction définit ce qu'il se passe lorsque la souris est cliquée.
function love.mousepressed(x,y,n)
  --  Si la balle était collée à la raquette au moment du clic, alors on la décolle et elle commence à bouger toute seule. On lui attribue une vitesse.
  if ball.isStuckOnPad == true then
    ball.isStuckOnPad = false
    ball.xspeed = 200
    ball.yspeed = -200
  end  
end



-- TOUCHE PRESSEE
function love.keypressed(key)

  print(key)
  
end
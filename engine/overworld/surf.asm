Surf::
	ld a,[wWalkBikeSurfState]
	ld [wWalkBikeSurfStateCopy],a
	cp a,2 ; is the player already surfing?
	jr z,.tryToStopSurfing
.tryToSurf
	call IsNextTileShoreOrWater
	jp c,SurfingAttemptFailed
	ld hl,TilePairCollisionsWater
	call CheckForTilePairCollisions
	jp c,SurfingAttemptFailed
.surf
	call .makePlayerMoveForward
	ld hl,wd730
	set 7,[hl]
	ld a,2
	ld [wWalkBikeSurfState],a ; change player state to surfing
	call PlayDefaultMusic ; play surfing music
	ld hl,SurfingGotOnText
	jp PrintText
.tryToStopSurfing
	xor a
	ld [hSpriteIndexOrTextID],a
	ld d,16 ; talking range in pixels (normal range)
	call IsSpriteInFrontOfPlayer2
	res 7,[hl]
	ld a,[hSpriteIndexOrTextID]
	and a ; is there a sprite in the way?
	jr nz,.cannotStopSurfing
	ld hl,TilePairCollisionsWater
	call CheckForTilePairCollisions
	jr c,.cannotStopSurfing
	ld hl,wTilesetCollisionPtr ; pointer to list of passable tiles
	ld a,[hli]
	ld h,[hl]
	ld l,a ; hl now points to passable tiles
	ld a,[wTileInFrontOfPlayer] ; tile in front of the player
	ld b,a
.passableTileLoop
	ld a,[hli]
	cp b
	jr z,.stopSurfing
	cp a,$ff
	jr nz,.passableTileLoop
.cannotStopSurfing
	ld hl,SurfingNoPlaceToGetOffText
	jp PrintText
.stopSurfing
	call .makePlayerMoveForward
	ld hl,wd730
	set 7,[hl]
	xor a
	ld [wWalkBikeSurfState],a ; change player state to walking
	dec a
	ld [wJoyIgnore],a
	call PlayDefaultMusic ; play walking music
	jp LoadWalkingPlayerSpriteGraphics
; uses a simulated button press to make the player move forward
.makePlayerMoveForward
	ld a,[wPlayerDirection] ; direction the player is going
	bit PLAYER_DIR_BIT_UP,a
	ld b,D_UP
	jr nz,.storeSimulatedButtonPress
	bit PLAYER_DIR_BIT_DOWN,a
	ld b,D_DOWN
	jr nz,.storeSimulatedButtonPress
	bit PLAYER_DIR_BIT_LEFT,a
	ld b,D_LEFT
	jr nz,.storeSimulatedButtonPress
	ld b,D_RIGHT
.storeSimulatedButtonPress
	ld a,b
	ld [wSimulatedJoypadStatesEnd],a
	xor a
	ld [wWastedByteCD39],a
	inc a
	ld [wSimulatedJoypadStatesIndex],a
	ret

SurfingGotOnText:
	TX_FAR _SurfingGotOnText
	db "@"

SurfingNoPlaceToGetOffText:
	TX_FAR _SurfingNoPlaceToGetOffText
	db "@"

SurfingAttemptFailed:
        ld hl,NoSurfingHereText
        xor a
        ld [wActionResultOrTookBattleTurn],a ; item use failed
        jp PrintText

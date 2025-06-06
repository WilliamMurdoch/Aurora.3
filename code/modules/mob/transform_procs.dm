/mob/living/carbon/human/proc/monkeyize(var/kpg=0)
	if (transforming)
		return
	for(var/obj/item/W in src)
		if (W==w_uniform) // will be torn
			continue
		drop_from_inventory(W)
	regenerate_icons()
	transforming = 1
	canmove = 0
	stunned = 1
	icon = null
	set_invisibility(101)
	var/atom/movable/overlay/animation = new /atom/movable/overlay( loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(48)
	//animation = null

	transforming = 0
	stunned = 0
	update_canmove()
	set_invisibility(initial(invisibility))

	if(!species.primitive_form) //If the creature in question has no primitive set, this is going to be messy.
		gib()
		return

	for(var/obj/item/W in src)
		drop_from_inventory(W)
	set_species(species.primitive_form)
	if(!kpg)
		dna.SetSEState(MONKEYBLOCK,1)

	to_chat(src, "<B>You are now [species.name]. </B>")
	qdel(animation)

	return src

/mob/living/carbon/human/proc/humanize(var/kpg=0) // we needed this a lot to be honest, why wasn't it made before?
	if (transforming)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	regenerate_icons()
	transforming = 1
	canmove = 0
	stunned = 1
	icon = null
	set_invisibility(101)
	var/atom/movable/overlay/animation = new /atom/movable/overlay( loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("monkey2h", animation)
	sleep(48)

	transforming = 0
	stunned = 0
	update_canmove()
	set_invisibility(initial(invisibility))

	if(!species.greater_form) //If the creature in question has no greater form set, this is going to be messy.
		gib()
		return

	for(var/obj/item/W in src)
		drop_from_inventory(W)
	set_species(species.greater_form)
	if(!kpg)
		dna.SetSEState(MONKEYBLOCK,0)

	to_chat(src, "<B>You are now [species.name]. </B>")
	qdel(animation)

	return src




/mob/abstract/new_player/AIize()
	spawning = 1
	return ..()

/mob/living/carbon/human/AIize(move=1) // 'move' argument needs defining here too because BYOND is dumb
	if (transforming)
		return
	for(var/t in organs)
		qdel(t)

	return ..(move)

/mob/living/carbon/AIize()
	if (transforming)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	transforming = 1
	canmove = 0
	icon = null
	set_invisibility(101)
	return ..()

/mob/proc/AIize(move=1)
	if(client)
		src.stop_sound_channel(CHANNEL_LOBBYMUSIC) // stop the jams for AIs)

	//The destination the mob will be spawned at
	var/final_destination = loc

	//If it's requested to move, select a location to spawn/move the mob to
	if(move)
		var/obj/loc_landmark
		for(var/obj/effect/landmark/start/sloc in GLOB.landmarks_list)
			if (sloc.name != "AI")
				continue
			if ((locate(/mob/living) in sloc.loc) || (locate(/obj/structure/AIcore) in sloc.loc))
				continue
			loc_landmark = sloc
		if (!loc_landmark)
			for(var/obj/effect/landmark/tripai in GLOB.landmarks_list)
				if (tripai.name == "tripai")
					if((locate(/mob/living) in tripai.loc) || (locate(/obj/structure/AIcore) in tripai.loc))
						continue
					loc_landmark = tripai
		if (!loc_landmark)
			for(var/obj/effect/landmark/start/sloc in GLOB.landmarks_list)
				if (sloc.name == "AI")
					loc_landmark = sloc

		if(loc_landmark.loc)
			final_destination = loc_landmark.loc


	var/mob/living/silicon/ai/O = new (final_destination, GLOB.base_law_type,,1)//No MMI but safety is in effect.
	O.set_invisibility(0)
	O.ai_restore_power_routine = 0

	if(mind)
		mind.transfer_to(O)
		O.mind.original = O
	else
		O.key = key

	O.on_mob_init()

	O.add_ai_verbs()

	O.rename_self("ai",1)

	O.client.init_verbs()
	spawn(0)	// Mobs still instantly del themselves, thus we need to spawn or O will never be returned
		qdel(src)
	return O

//human -> robot
/mob/living/carbon/human/proc/Robotize()
	if (transforming)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	regenerate_icons()
	transforming = 1
	canmove = 0
	icon = null
	set_invisibility(101)
	for(var/t in organs)
		qdel(t)

	var/mob/living/silicon/robot/O = new /mob/living/silicon/robot( loc )

	// cyborgs produced by Robotize get an automatic power cell
	O.cell = new(O)
	O.cell.maxcharge = 7500
	O.cell.charge = 7500

	O.gender = gender
	O.set_invisibility(0)

	if(mind)		//TODO
		mind.transfer_to(O)
		if(O.mind.assigned_role == "Cyborg")
			O.mind.original = O
		else if(mind && mind.special_role)
			O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
	else
		O.key = key

	O.forceMove(loc)
	O.job = "Cyborg"
	if(O.mind.assigned_role == "Cyborg")
		if(O.mind.role_alt_title == "Robot")
			O.mmi = new /obj/item/device/mmi/digital/robot(O)
		else
			O.mmi = new /obj/item/device/mmi(O)

		O.mmi.transfer_identity(src)

	callHook("borgify", list(O))
	O.Namepick()
	if(O.client)
		O.client.init_verbs()

	spawn(0)	// Mobs still instantly del themselves, thus we need to spawn or O will never be returned
		qdel(src)
	return O

//human -> alien

/mob/living/carbon/human/proc/slimeize(adult as num, reproduce as num)
	if (transforming)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	regenerate_icons()
	transforming = 1
	canmove = 0
	icon = null
	set_invisibility(101)
	for(var/t in organs)
		qdel(t)

	var/mob/living/carbon/slime/new_slime
	if(reproduce)
		var/number = pick(14;2,3,4)	//reproduce (has a small chance of producing 3 or 4 offspring)
		var/list/babies = list()
		for(var/i=1,i<=number,i++)
			var/mob/living/carbon/slime/M = new/mob/living/carbon/slime(loc)
			M.nutrition = round(nutrition/number)
			step_away(M,src)
			babies += M
		new_slime = pick(babies)
	else
		new_slime = new /mob/living/carbon/slime(loc)
		if(adult)
			new_slime.is_adult = 1

	new_slime.key = key

	to_chat(new_slime, "<B>You are now a slime. Skreee!</B>")
	qdel(src)
	return

/mob/living/carbon/human/proc/corgize()
	if (transforming)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	regenerate_icons()
	transforming = 1
	canmove = 0
	icon = null
	set_invisibility(101)
	for(var/t in organs)	//this really should not be necessary
		qdel(t)

	var/mob/living/simple_animal/corgi/new_corgi = new /mob/living/simple_animal/corgi (loc)
	new_corgi.set_intent(I_HURT)
	new_corgi.key = key

	to_chat(new_corgi, "<B>You are now a Corgi. Yap Yap!</B>")
	qdel(src)
	return

/mob/living/carbon/human/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		to_chat(usr, SPAN_WARNING("Sorry but this mob type is currently unavailable."))
		return

	if(transforming)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)

	regenerate_icons()
	transforming = 1
	canmove = 0
	icon = null
	set_invisibility(101)

	for(var/t in organs)
		qdel(t)

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.set_intent(I_HURT)


	to_chat(new_mob, "You suddenly feel more... animalistic.")
	spawn()
		qdel(src)
	return

/mob/proc/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		to_chat(usr, SPAN_WARNING("Sorry but this mob type is currently unavailable."))
		return

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.set_intent(I_HURT)
	to_chat(new_mob, "You feel more... animalistic")

	qdel(src)

/* Certain mob types have problems and should not be allowed to be controlled by players.
 *
 * This proc is here to force coders to manually place their mob in this list, hopefully tested.
 * This also gives a place to explain -why- players shouldnt be turn into certain mobs and hopefully someone can fix them.
 */
/mob/proc/safe_animal(var/MP)

//Bad mobs! - Remember to add a comment explaining what's wrong with the mob
	if(!MP)
		return 0	//Sanity, this should never happen.

	if(ispath(MP, /mob/living/simple_animal/space_worm))
		return 0 //Unfinished. Very buggy, they seem to just spawn additional space worms everywhere and eating your own tail results in new worms spawning.

	if(ispath(MP, /mob/living/simple_animal/construct/armored))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/wraith))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/builder))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

//Good mobs!
	if(ispath(MP, /mob/living/simple_animal/cat))
		return 1
	if(ispath(MP, /mob/living/simple_animal/corgi))
		return 1
	if(ispath(MP, /mob/living/simple_animal/crab))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/carp))
		return 1
	if(ispath(MP, /mob/living/simple_animal/mushroom))
		return 1
	if(ispath(MP, /mob/living/simple_animal/shade))
		return 1
	if(ispath(MP, /mob/living/simple_animal/tomato))
		return 1
	if(ispath(MP, /mob/living/simple_animal/rat))
		return 1 //It is impossible to pull up the player panel for rats (Fixed! - Nodrak)
	if(ispath(MP, /mob/living/simple_animal/hostile/bear))
		return 1 //Bears will auto-attack mobs, even if they're player controlled (Fixed! - Nodrak)
	if(ispath(MP, /mob/living/simple_animal/parrot))
		return 1 //Parrots are no longer unfinished! -Nodrak

	//Not in here? Must be untested!
	return 0

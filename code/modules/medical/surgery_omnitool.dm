/*
CONTAINS:
		/obj/item/scalpel
		/obj/item/circular_saw,
		/obj/item/surgical_spoon,
		/obj/item/scissors/surgical_scissors,
		/obj/item/hemostat,
		/obj/item/suture,
*/

/obj/item/tool/surgery_omnitool
	name = "surgical omnitool"
	desc = "Multiple surgical tools in one, like an old-fashioned Swiss army knife. Truly, we are living in the future."
	icon = 'icons/obj/surgery.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/omnitool.dmi' //kinda a lot of inhands for one thing, this can stay for now
	uses_multiple_icon_states = 1
	var/prefix = "surgery_omnitool"

	fiddleType = /datum/contextAction/fiddle/surgery_omnitool

	var/omni_mode = "scalpel"

	hint = "Use in hand to cycle modes. Press X to fiddle to a specific mode."


	New()
		..()
		src.change_mode(omni_mode)

	attack_self(var/mob/user as mob)
		// cycle between modes
		var/new_mode = null
		switch (src.omni_mode)
			if ("scalpel") new_mode = "saw"
			if ("saw") new_mode = "spoon"
			if ("spoon") new_mode = "scissors"
			if ("scissors") new_mode = "hemostat"
			if ("hemostat") new_mode = "suture"
			if ("suture") new_mode = "scalpel"
		if (new_mode)
			src.change_mode(new_mode, user)

	attack(mob/living/carbon/M as mob, mob/user as mob)
		if (src.omni_mode == "scalpel")
			if (!scalpel_surgery(M, user))
				return ..()
		else if (src.omni_mode == "saw")
			if (!saw_surgery(M, user))
				return ..()
		else if (src.omni_mode == "spoon")
			if (!spoon_surgery(M, user))
				return ..()
		else if (src.omni_mode == "scissors")
			if (!snip_surgery(M, user))
				return ..()
		else if (src.omni_mode == "hemostat")
			if (!ishuman(M))
				if (user.a_intent == INTENT_HELP)
					return
				return ..()
			var/mob/living/carbon/human/H = M
			var/surgery_status = H.get_surgery_status(user.zone_sel.selecting)
			if (!surgery_status)
				if (user.a_intent == INTENT_HELP)
					return
				return ..()
			if (!surgeryCheck(H, user))
				if (user.a_intent == INTENT_HELP)
					return
				return ..()
			if (H.bleeding)
				H.tri_message("<span class='alert'><b>[user]</b> begins clamping the bleeders in [H == user ? "[his_or_her(H)]" : "[H]'s"] incision with [src].</span>",\
				user, "<span class='alert'>You begin clamping the bleeders in [user == H ? "your" : "[H]'s"] incision with [src].</span>",\
				H, "<span class='alert'>[H == user ? "You begin" : "<b>[user]</b> begins"] clamping the bleeders in your incision with [src].</span>")

				if (!do_mob(user, H, clamp(surgery_status * 4, 0, 100)))
					user.visible_message("<span class='alert'><b>[user]</b> was interrupted!</span>",\
					"<span class='alert'>You were interrupted!</span>")
					return

				H.tri_message("<span class='notice'><b>[user]</b> clamps the bleeders in [H == user ? "[his_or_her(H)]" : "[H]'s"] incision with [src].</span>",\
				user, "<span class='notice'>You clamp the bleeders in [user == H ? "your" : "[H]'s"] incision with [src].</span>",\
				H, "<span class='notice'>[H == user ? "You clamp" : "<b>[user]</b> clamps"] the bleeders in your incision with [src].</span>")

				if (H.bleeding)
					repair_bleeding_damage(H, 50, rand(2,5))
					return

				return ..()

		else if (src.omni_mode == "suture")
			if (!suture_surgery(M, user))
				return ..()
		else
			..()

	get_desc(var/dist)
		if (dist < 3)
			. = "<span class='notice'>It is currently set to [src.omni_mode] mode.</span>"

	proc/change_mode(var/new_mode, var/mob/holder)
		tooltip_rebuild = 1
		switch (new_mode)
			if ("scalpel")
				src.omni_mode = "scalpel"
				// based on /obj/item/scalpel
				set_icon_state("[prefix]-scalpel")
				src.tool_flags = TOOL_CUTTING
				src.force = 5
				src.throwforce = 5
				src.throw_range = 5
				src.throw_speed = 3
				src.stamina_damage = 5
				src.hit_type = DAMAGE_CUT
				src.hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
			if ("saw")
				src.omni_mode = "saw"
				// based on /obj/item/circular_saw
				set_icon_state("[prefix]-saw")
				src.tool_flags = TOOL_SAWING
				src.force = 8
				src.throwforce = 3
				src.throw_range = 5
				src.throw_speed = 3
				src.stamina_damage = 5
				src.hit_type = DAMAGE_CUT
				src.hitsound = 'sound/impact_sounds/circsaw.ogg'
			if ("spoon")
				src.omni_mode = "spoon"
				// based on /obj/item/surgical_spoon
				set_icon_state("[prefix]-spoon")
				src.tool_flags = TOOL_SPOONING
				src.force = 5.0
				src.throwforce = 5.0
				src.throw_range = 5
				src.throw_speed = 3
				src.stamina_damage = 5
				src.hit_type = DAMAGE_STAB
				src.hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
			if ("scissors")
				src.omni_mode = "scissors"
				// based on /obj/item/scissors/surgical_scissors
				set_icon_state("[prefix]-scissors")
				src.tool_flags = TOOL_SNIPPING
				src.force = 8
				src.throwforce = 5
				src.throw_range = 5
				src.throw_speed = 3
				src.stamina_damage = 5
				src.hit_type = DAMAGE_STAB
				src.hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
			if ("hemostat")
				src.omni_mode = "hemostat"
				// based on /obj/item/hemostat
				set_icon_state("[prefix]-hemostat")
				src.tool_flags = null
				src.force = 1.5
				src.throwforce = 3
				src.throw_range = 6
				src.throw_speed = 3
				src.stamina_damage = 0
				src.hit_type = DAMAGE_STAB
				src.hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
			if ("suture")
				src.omni_mode = "suture"
				//based on /obj/item/suture
				set_icon_state("[prefix]-cutting")
				src.tool_flags = null
				src.force = 1
				src.throwforce = 1
				src.throw_range = 20
				src.throw_speed = 4
				src.stamina_damage = 0
				src.hit_type = DAMAGE_STAB
				src.hitsound = null
		if (holder)
			holder.update_inhands()


/obj/item/tool/surgery_omnitool/silicon
	prefix = "silicon-surgery-omnitool"
	desc = "A set of tools on telescopic arms. It's the robotic future!"



ABSTRACT_TYPE(/datum/contextAction/fiddle/surgery_omnitool)
/datum/contextAction/fiddle/surgery_omnitool
	checkRequirements(var/obj/item/tool/surgery_omnitool/target, var/mob/user)
		return istype(target)

	scalpel
		name = "scalpel"
		icon_state = "omni_prying"
		execute(var/obj/item/tool/surgery_omnitool/target, var/mob/user)
			target.change_mode("scalpel", user)

	saw
		name = "circular saw"
		icon_state = "omni_screwing"
		execute(var/obj/item/tool/surgery_omnitool/target, var/mob/user)
			target.change_mode("saw", user)

	spoon
		name = "surgical spoon"
		icon_state = "omni_snipping"
		execute(var/obj/item/tool/surgery_omnitool/target, var/mob/user)
			target.change_mode("spoon", user)

	scissors
		name = "surgical scissors"
		icon_state = "omni_pulsing"
		execute(var/obj/item/tool/surgery_omnitool/target, var/mob/user)
			target.change_mode("scissors", user)

	hemostat
		name = "hemostat"
		icon_state = "omni_snipping"
		execute(var/obj/item/tool/surgery_omnitool/target, var/mob/user)
			target.change_mode("hemostat", user)

	suture
		name = "suture"
		icon_state = "omni_wrenching"
		execute(var/obj/item/tool/surgery_omnitool/target, var/mob/user)
			target.change_mode("suture", user)

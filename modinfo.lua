-- Mod Information

name = "DKC Trilogy Music Pack Revisited"
description = [[ 
A collection of music from the original Donkey Kong Country trilogy. Based on the DKC Trilogy Music Pack mod by Phasmite/Raider, adds more tracks and fixes broken ones.

Visit the mod page for a full list of tracks!
]]
author = "Mikul"
version = "1.0.0"
api_version = 10

forumthread = ""
icon_atlas = "modicon.xml"
icon = "modicon.tex"

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false

all_clients_require_mod = false
client_only_mod = true

-- Configuration Menu

local function Header(header, hover)
	return {
		name = header,
		hover = hover,
		options = {
			{description = "", data = ""}
		},
		default = ""
	}
end

configuration_options =
{
	Header("Music Mode Options", "When to play music in-game."),
	{
		name = "music_mode",
		label = "Music Mode",
		options = {
			{
				description = "Working",
				data = "busy",
				hover = "Music only plays if you're working."
			},
			{
				description = "Continuous",
				data = "continuous",
				hover = "Music will always play. Dawn/dusk/insanity stingers will not play."
			}
		},
		default = "continuous",
	},
	{
		name = "title_music",
		label = "Main Menu Music",
		options = {
			{
				description = "Disabled",
				data = "no",
				hover = "Use the default main menu music."
			},
			{
				description = "Enabled",
				data = "yes",
				hover = "Use custom music on the main menu."
			}
		},
		default = "yes"
	},

	Header("Track Options", "Swap the music that plays in specific situations."),
	{
		name = "autumn_night_music",
		label = "Autumn Night Music",
		options = {
			{
				description = "Classic",
				data = "classic",
				hover = "Use the Autumn night music from the original music pack."
			},
			{
				description = "Revisited",
				data = "refresh",
				hover = "Use the updated Autumn night music."
			}
		},
		default = "refresh"
	},
	{
		name = "winter_dusk_music",
		label = "Winter Dusk Music",
		options = {
			{
				description = "Classic",
				data = "classic",
				hover = "Use the Winter dusk music from the original music pack."
			},
			{
				description = "Revisited",
				data = "refresh",
				hover = "Use the updated Winter dusk music."
			}
		},
		default = "refresh"
	},
	{
		name = "spring_fight_music",
		label = "Spring Fight Music",
		options = {
			{
				description = "Classic",
				data = "classic",
				hover = "Use the Spring fight music from the original music pack."
			},
			{
				description = "Revisited",
				data = "refresh",
				hover = "Use the updated Spring fight music."
			}
		},
		default = "refresh"
	},
	{
		name = "nightmare_music",
		label = "Nightmare Phase Music",
		options = {
			{
				description = "Disabled",
				data = "no",
				hover = "Use the same ruins work music for all phases."
			},
			{
				description = "Enabled",
				data = "yes",
				hover = "Use a spookier ruins work music during Nightmare phase."
			}
		},
		default = "yes"
	}
}
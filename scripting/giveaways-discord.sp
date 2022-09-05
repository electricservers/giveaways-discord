#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <giveaways>
#include <discord>
#include <autoexecconfig>

#define PLUGIN_VERSION "1.0"

ConVar g_cvWebhook;
char g_cWebhook[512];

public Plugin myinfo = 
{
	name = "Giveaways Discord Announcer", 
	author = "ampere", 
	description = "Announces giveaways events to Discord.", 
	version = PLUGIN_VERSION, 
	url = "https://electricservers.com.ar"
};

public void OnPluginStart() {
	AutoExecConfig_SetCreateFile(true);
	AutoExecConfig_SetFile("giveaways-discord");
	
	g_cvWebhook = AutoExecConfig_CreateConVar("sm_giveawaysdiscord_webhook", "", "Discord webhook.");
	
	g_cvWebhook.GetString(g_cWebhook, sizeof(g_cWebhook));
	g_cvWebhook.AddChangeHook(OnWebhookChange);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
}

public void Giveaways_OnGiveawayEnded(int creator, int winner, int participants, const char[] prize) {
	if (winner == 0) {
		return;
	}
	
	DiscordWebHook hook = new DiscordWebHook(g_cWebhook);
	hook.SlackMode = false;
	
	hook.SetUsername("Electric Sorteos");
	
	MessageEmbed embed = new MessageEmbed();
	
	embed.SetColor("15905574");
	
	char title[64];
	Format(title, sizeof(title), "¡El jugador %N ganó un sorteo 🎉🎊!", winner);
	embed.SetTitle(title);
	
	if (prize[0] != '\0') {
		char desc[128];
		Format(desc, sizeof(desc), "🎈 El premio es: **%s**", prize);
		embed.SetDescription(desc);
	}
	
	char steamid[32];
	GetClientAuthId(winner, AuthId_Steam2, steamid, sizeof(steamid));
	Format(steamid, sizeof(steamid), "`%s`", steamid);
	embed.AddField("**🆔 Steam ID**", steamid, true);
	
	char time[64];
	FormatTime(time, sizeof(time), "`%d/%m/%y a las %R`");
	embed.AddField("**🕒 Fecha y hora**", time, true);
	
	char author[64];
	Format(author, sizeof(author), "`%N`", creator);
	embed.AddField("**👤 Sorteado por**", author, true);
	
	hook.Embed(embed);
	hook.Send();
	delete hook;
}

public void OnWebhookChange(ConVar convar, const char[] oldValue, const char[] newValue) {
	strcopy(g_cWebhook, sizeof(g_cWebhook), newValue);
} 
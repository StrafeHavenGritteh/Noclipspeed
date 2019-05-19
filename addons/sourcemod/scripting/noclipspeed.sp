#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

public Plugin myinfo = 
{
    name = "Noclip Speed",
    author = "SlidyBat",
    description = "Allows players to set their noclip speed",
    version = "1.0",
    url = ""
};

ConVar sv_noclipspeed;
int g_iDefaultNoclipSpeed;
int g_iNoclipSpeed[MAXPLAYERS + 1];

public void OnPluginStart()
{
    RegConsoleCmd( "sm_noclipspeed", Command_NoclipSpeed, "Sets player's sv_noclipspeed value" );

    sv_noclipspeed = FindConVar( "sv_noclipspeed" );
    sv_noclipspeed.Flags &= ~FCVAR_NOTIFY;
    
    g_iDefaultNoclipSpeed = sv_noclipspeed.IntValue;
    for( int i = 1; i <= MaxClients; i++ )
    {
        g_iNoclipSpeed[i] = g_iDefaultNoclipSpeed;
    }
}

public void OnPluginEnd()
{
    // restore default value before plugin was loaded
    sv_noclipspeed.IntValue = g_iDefaultNoclipSpeed;
}

public void OnClientPutInServer( int client )
{
    g_iNoclipSpeed[client] = g_iDefaultNoclipSpeed;
    SDKHook( client, SDKHook_PreThinkPost, Hook_PreThinkPost );
}

public void Hook_PreThinkPost( int client )
{
    sv_noclipspeed.IntValue = g_iNoclipSpeed[client];
}

public Action Command_NoclipSpeed( int client, int args )
{
    if( args != 1 )
    {
        ReplyToCommand( client, "[SM] Usage: sm_noclipspeed <speed>" );
        return Plugin_Handled;
    }
    
    char arg[16];
    GetCmdArgString( arg, sizeof(arg) );
    
    sv_noclipspeed.ReplicateToClient( client, arg );
    
    int speed = StringToInt( arg );
    g_iNoclipSpeed[client] = speed;
    
    ReplyToCommand( client, "[SM] sv_noclipspeed set to %i", speed );
    return Plugin_Handled;
}  

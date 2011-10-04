{include file="_header.tpl" enable_tabs=true}
{include file="_statusbar.tpl"}

<div class="container_24">

  <div role="application" id="tabs">
    
    <ul>
      <li><a href="#plugins">Plugins</a></li>
      {if $user_is_admin}<li><a id="app-settings-tab" href="#app_settings">Application</a></li>{/if}
      <li><a href="#instances">Account</a></li>
      {if $user_is_admin}<li><a href="#ttusers">Users</a></li>{/if}
    </ul>
    
    <div class="section thinkup-canvas clearfix" id="plugins">
      <div class="alpha omega grid_22 prefix_1 clearfix prepend_20 append_20">
        <div class="append_20 clearfix">
        {include file="_usermessage.tpl" field="account"}
          {if $installed_plugins}
            {foreach from=$installed_plugins key=ipindex item=ip name=foo}
              {if $smarty.foreach.foo.first}
                <div class="clearfix header">
                  <div class="grid_18 alpha">name</div>
                  {if $user_is_admin}
                  <div class="grid_4 omega">activate/deactivate</div>
                  {/if}
                </div>
              {/if}
              {if $user_is_admin || $ip->is_active}
              <div class="clearfix bt append prepend">
                <div class="grid_18 small alpha">
                    <a href="?p={if $ip->folder_name eq 'googleplus'}{'google+'|urlencode}{else}{$ip->folder_name}{/if}"><span id="spanpluginimage{$ip->id}"><img src="{$site_root_path}plugins/{$ip->folder_name}/{$ip->icon}" class="float-l" style="margin-right:5px;"></span>
                    {if $ip->is_active}{if !$ip->isConfigured()}<span class="ui-icon ui-icon-alert" style="float: left; margin:.3em 0.3em 0 0;"></span>{/if}{/if}
                    <span {if !$ip->is_active}style="display:none;padding:5px;"{/if} id="spanpluginnamelink{$ip->id}">{$ip->name}</span></a>
                    <span {if $ip->is_active}style="display:none;padding:5px;"{/if} id="spanpluginnametext{$ip->id}">{$ip->name}</span><br >
                    <span style="color:#666"><small>{$ip->description}</small></span><br>
                </div>
                {if $user_is_admin}
                <div class="grid_4 omega">
                  <span id="spanpluginactivation{$ip->id}">
                      <input type="submit" name="submit" class="tt-button ui-state-default ui-priority-secondary ui-corner-all btnToggle" id="{$ip->id}" value="{if $ip->is_active}Deactivate{else}Activate{/if}" />
                  </span>
                  <span style="display: none;padding:5px;" class='ui-state-success ui-corner-all mt_10' id="message{$ip->id}"></span>
                  </div>
                {/if}
              </div>
              {/if}
            {/foreach}
          {else}
            <a href="?m=manage" class="tt-button ui-state-default tt-button-icon-left ui-corner-all"><span class="ui-icon ui-icon-circle-arrow-w"></span>Back to plugins</a>
          {/if}
        </div>
        {if $body}
          {$body}
        {/if}
      </div>
    </div> <!-- end #plugins -->

    {if $user_is_admin}
    <div class="section thinkup-canvas clearfix" id="app_settings">
        <div style="text-align: center" id="app_setting_loading_div">
            Loading application settings...<br /><br />
            <img src="{$site_root_path}assets/img/loading.gif" width="31" height="31" />
        </div>
        <div id="app_settings_div" style="display: none;">
         {include file="account.appconfig.tpl"}
        </div>
        <script type="text/javascript"> var site_root_path = '{$site_root_path}';</script>
        <script type="text/javascript" src="{$site_root_path}assets/js/appconfig.js"></script>
        
   <div class="prepend_20">
    <div class="help-container">{insert name="help_link" id='backup'}</div>
    <h1>Back Up and Export Data</h1>

    <p><br />
    <a href="{$site_root_path}install/backup.php">Back up ThinkUp's entire database</a> (highly recommended before upgrading ThinkUp)<br /><br />
    <a href="{$site_root_path}install/exportuserdata.php">Export a single service user's data</a> (for transfer into another existing ThinkUp database)
    </p>
  </div>
        
    </div> <!-- end #app_setting -->
    {/if}

    <div class="sections" id="instances">
      <div class="thinkup-canvas clearfix">
        <div class="alpha omega grid_22 prefix_1 clearfix prepend_20 append_20">
        {include file="_usermessage.tpl" field='password'}
        <div class="help-container">{insert name="help_link" id='account'}</div>
        <h1>Password</h1><br />
          <form name="changepass" method="post" action="index.php?m=manage#instances" class="prepend_20 append_20">
            <div class="clearfix">
              <div class="grid_9 prefix_1 right"><label for="oldpass">Current password:</label></div>
              <div class="grid_9 left" style="overflow: hidden; margin: 0px 0px 10px 5px;">
                <input name="oldpass" type="password" id="oldpass">
                {insert name="csrf_token"}<!-- reset password -->
              </div>
            </div>
            <div class="clearfix">
              <div class="grid_9 prefix_1 right"><label for="pass1">New password:</label></div>
              <div class="grid_9 left">
                <input name="pass1" type="password" id="pass1">
                <br>
                <div class="ui-state-highlight ui-corner-all" style="margin: 10px 0px 10px 0px; padding: .5em 0.7em;"> 
                  <p>
                    <span class="ui-icon ui-icon-info" style="float: left; margin:.3em 0.3em 0 0;"></span>
                    Must be at least 5 characters.
                  </p>
                </div>
              </div>
              <div class="clearfix append_bottom">
                <div class="grid_9 prefix_1 right">
                  <label for="pass2">Re-type new password:</label>
                </div>
                <div class="grid_9 left" style="overflow: hidden; margin: 0px 0px 10px 5px;">
                  <input name="pass2" type="password" id="pass2">
                </div>
              </div>
              <div class="prefix_10 grid_9 left">
                <input type="submit" id="login-save" name="changepass" value="Change password" class="tt-button ui-state-default ui-priority-secondary ui-corner-all">
              </div>
            </div>
          </form>
<br><br>
<div class="help-container">{insert name="help_link" id='rss'}</div>
<h1>Automate ThinkUp Crawls</h1><br />

<p>To set up ThinkUp to update automatically, subscribe to this secret RSS feed URL in your favorite news reader.</p>

<div style="text-align: center; padding: 20px 0px 20px 0px;width:100%;">
<a href="{$rss_crawl_url}" class="tt-button ui-state-default tt-button-icon-right ui-corner-all"><span class="ui-icon ui-icon-circle-arrow-e"></span>Secret RSS Feed to Update ThinkUp</a>
<div style="clear:all">&nbsp;<br><br><br></div>
</div>

<p>Alternately, use the command below to set up a cron job that runs hourly to update your posts. (Be sure to change yourpassword to your real password!)
<br />
<div style="background-color:black;color:white;"><small><code style="font-family:Courier;">{$cli_crawl_command}</code></small></div>
<br /><br /><br/>
</p>

<h1>Reset Your API Key</h1><br />
{include file="_usermessage.tpl" field='api_key'}

<p>Accidentally share your secret RSS URL? Reset your ThinkUp API key (and RSS feed URL) here.<br><br></p>

          <div style="text-align: center; border-top: solid gray 1px; padding: 20px 0px 20px 0px;">
             <strong>Your Current ThinkUp API Key:</strong>
             <span id="hidden_api_key" style="display: none;">{$owner->api_key}</span>
             <span id="show_api_key">
             <a href="javascript:;" onclick="$('#show_api_key').hide(); $('#hidden_api_key').show();">
             Click to view</a>
             </span>
          </div> 

          <form method="post" action="index.php?m=manage#instances" class="prepend_20 append_20" 
          style="border-top: solid gray 1px; padding: 20px 0px 0px 0px;" id="api-key-form">
      <div class="grid_10 prefix_9 left">
                <input type="hidden" name="reset_api_key" value="Reset API Key" />
                <span id="apikey_conf" style="display: none;">
                Don't forget! If you reset your API key, you will need to update your ThinkUp crawler RSS feed subscription. This action cannot be undone.
                </span>
                <input type="button" value="Reset Your API Key" 
                class="tt-button ui-state-default ui-priority-secondary ui-corner-all"
                {literal}
                onclick="if(confirm($('#apikey_conf').html().trim())) { $('#api-key-form').submit();}">
                {/literal}
              </div>
              {insert name="csrf_token"}<!-- reset api_key -->
          </form>
        </div>
      </div>
    </div> <!-- end #instances -->
    
    {if $user_is_admin}
      <div class="section" id="ttusers">
        <div class="thinkup-canvas clearfix">
          <div class="alpha omega grid_20 prefix_1 clearfix prepend_20 append_20">
          <div class="help-container">{insert name="help_link" id='users'}</div>
            <h1>All Users</h1><br />
            <ul class="user-accounts">
              {foreach from=$owners key=oid item=o}
                <li>
                  <b>{$o->full_name} ({$o->email})</b>{if $o->last_login neq '0000-00-00'}, last logged in {$o->last_login}{/if}{if $o->is_admin}, Administrator<br />{/if}
                  {if !$o->is_admin}
                  <input type="submit" name="submit" class="tt-button ui-state-default ui-priority-secondary ui-corner-all toggleOwnerButton" id="user{$o->id}" value="{if $o->is_activated}Deactivate{else}Activate{/if}" />
                  {/if}
                  <span style="display:none;padding:5px;" class='ui-state-success ui-corner-all mt_10' id="message1{$o->id}"></span>
                  
                  {if $o->instances neq null}
                    <ul>
                      {foreach from=$o->instances key=iid item=i}
                        <li>
                          {$i->network_username} ({$i->network|capitalize})
                          {if !$i->is_active} (paused){/if}
                        </li>
                      {/foreach}
                    </ul>
                  {/if}
                </li>
              {/foreach}
            </ul>
          </div>
          
         <div class="alpha omega grid_20 prefix_1 clearfix prepend_20 append_20">
        <h1>Invite User</h1>
        {include file="_usermessage.tpl" field='invite'}
          <form name="invite" method="post" action="index.php?m=manage#ttusers" class="prepend_20 append_20">
                {insert name="csrf_token"}<input type="submit" id="login-save" name="invite" value="Create Invitation" 
                class="tt-button ui-state-default ui-priority-secondary ui-corner-all">
          </form>
        </div>
          
          
        </div> <!-- end .thinkup-canvas -->
      </div> <!-- end #ttusers -->
    {/if} <!-- end is_admin -->



   
  </div>
</div>

<script type="text/javascript">
  {literal}
$(function() {
    $(".btnPub").click(function() {
      var element = $(this);
      var u = element.attr("id");
      var dataString = 'u=' + u + "&p=1&csrf_token=" + window.csrf_token; // toggle public on
      $.ajax({
        type: "GET",
        url: "{/literal}{$site_root_path}{literal}account/toggle-public.php",
        data: dataString,
        success: function() {
          $('#div' + u).html("<span class='ui-state-success ui-corner-all' id='message" + u + "'></span>");
          $('#message' + u).html("Set to public!").hide().fadeIn(1500, function() {
            $('#message' + u);
          });
        }
      });
      return false;
    });

    $(".btnPriv").click(function() {
      var element = $(this);
      var u = element.attr("id");
      var dataString = 'u=' + u + "&p=0&csrf_token=" + window.csrf_token; // toggle public off
      $.ajax({
        type: "GET",
        url: "{/literal}{$site_root_path}{literal}account/toggle-public.php",
        data: dataString,
        success: function() {
          $('#div' + u).html("<span class='ui-state-success ui-corner-all' id='message" + u + "'></span>");
          $('#message' + u).html("Set to private!").hide().fadeIn(1500, function() {
            $('#message' + u);
          });
        }
      });
      return false;
    });
  });

  $(function() {
    $(".btnPlay").click(function() {
      var element = $(this);
      var u = element.attr("id");
      var dataString = 'u=' + u + "&p=1&csrf_token=" + window.csrf_token; // toggle active on
      $.ajax({
        type: "GET",
        url: "{/literal}{$site_root_path}{literal}account/toggle-active.php",
        data: dataString,
        success: function() {
          $('#divactivate' + u).html("<span class='ui-state-success ui-corner-all mt_10' id='message" + u + "'></span>");
          $('#message' + u).html("Started!").hide().fadeIn(1500, function() {
            $('#message' + u);
          });
        }
      });
      return false;
    });

    $(".btnPause").click(function() {
      var element = $(this);
      var u = element.attr("id");
      var dataString = 'u=' + u + "&p=0&csrf_token=" + window.csrf_token; // toggle active off
      $.ajax({
        type: "GET",
        url: "{/literal}{$site_root_path}{literal}account/toggle-active.php",
        data: dataString,
        success: function() {
          $('#divactivate' + u).html("<span class='ui-state-success ui-corner-all mt_10' id='message" + u + "'></span>");
          $('#message' + u).html("Paused!").hide().fadeIn(1500, function() {
            $('#message' + u);
          });
        }
      });
      return false;
    });
  });

  $(function() {
    var activate = function(u) {
      var dataString = 'pid=' + u + "&a=1&csrf_token=" + window.csrf_token; // toggle plugin on
      $.ajax({
        type: "GET",
        url: "{/literal}{$site_root_path}{literal}account/toggle-pluginactive.php",
        data: dataString,
        success: function() {
          $('#spanpluginactivation' + u).css('display', 'none');
          $('#message' + u).html("Activated!").hide().fadeIn(1500, function() {
            $('#message' + u);
          });
          $('#spanpluginnamelink' + u).css('display', 'inline');
          $('#' + u).val('Deactivate');
          $('#spanpluginnametext' + u).css('display', 'none');
          $('#' + u).removeClass('btnActivate');
          $('#' + u).addClass('btnDectivate');
          setTimeout(function() {
              $('#message' + u).css('display', 'none');
              $('#spanpluginactivation' + u).hide().fadeIn(1500);
            },
            2000
          );
        }
      });
      return false;
    };

    var deactivate = function(u) {
      var dataString = 'pid=' + u + "&a=0&csrf_token=" + window.csrf_token; // toggle plugin off
      $.ajax({
        type: "GET",
        url: "{/literal}{$site_root_path}{literal}account/toggle-pluginactive.php",
        data: dataString,
        success: function() {
          $('#spanpluginactivation' + u).css('display', 'none');
          $('#message' + u).html("Deactivated!").hide().fadeIn(1500, function() {
            $('#message' + u);
          });
          $('#spanpluginnamelink' + u).css('display', 'none');
          $('#spanpluginnametext' + u).css('display', 'inline');
          $('#' + u).val('Activate');
          $('#' + u).removeClass('btnDeactivate');
          $('#' + u).addClass('btnActivate');
          setTimeout(function() {
              $('#message' + u).css('display', 'none');
              $('#spanpluginactivation' + u).hide().fadeIn(1500);
            },
            2000
          );
        }
      });
      return false;
    };

    $(".btnToggle").click(function() {
      if($(this).val() == 'Activate') {
        activate($(this).attr("id"));
      } else {
        deactivate($(this).attr("id"));
      }
    });
  });
  
    $(function() {
    var activateOwner = function(u) {
      //removing the "user" from id here to stop conflict with plugin    
      u = u.substr(4);
      var dataString = 'oid=' + u + "&a=1&csrf_token=" + window.csrf_token; // toggle owner active on
      $.ajax({
        type: "GET",
        url: "{/literal}{$site_root_path}{literal}account/toggle-owneractive.php",
        data: dataString,
        success: function() {
          $('#spanowneractivation' + u).css('display', 'none');
          $('#message1' + u).html("Activated!").hide().fadeIn(1500, function() {
            $('#message1' + u);
          });
          $('#spanownernamelink' + u).css('display', 'inline');
          $('#user' + u).val('Deactivate');
          $('#spanownernametext' + u).css('display', 'none');
          $('#user' + u).removeClass('btnActivate');
          $('#user' + u).addClass('btnDectivate');
          setTimeout(function() {
              $('#message1' + u).css('display', 'none');
              $('#spanowneractivation' + u).hide().fadeIn(1500);
            },
            2000
          );
        }
      });
      return false;
    };

    var deactivateOwner = function(u) {
      //removing the "user" from id here to stop conflict with plugin
      u = u.substr(4);
      var dataString = 'oid=' + u + "&a=0&csrf_token=" + window.csrf_token; // toggle owner active off
      $.ajax({
        type: "GET",
        url: "{/literal}{$site_root_path}{literal}account/toggle-owneractive.php",
        data: dataString,
        success: function() {
          $('#spanowneractivation' + u).css('display', 'none');
          $('#message1' + u).html("Deactivated!").hide().fadeIn(1500, function() {
            $('#message1' + u);
          });
          $('#spanownernamelink' + u).css('display', 'none');
          $('#spanownernametext' + u).css('display', 'inline');
          $('#user' + u).val('Activate');
          $('#user' + u).removeClass('btnDeactivate');
          $('#user' + u).addClass('btnActivate');
          setTimeout(function() {
              $('#message1' + u).css('display', 'none');
              $('#spanowneractivation' + u).hide().fadeIn(1500);
            },
            2000
          );
        }
      });
      return false;
    };

    $(".toggleOwnerButton").click(function() {
      if($(this).val() == 'Activate') {
        activateOwner($(this).attr("id"));
      } else {
        deactivateOwner($(this).attr("id"));
      }
    });
  });

  {/literal}
</script>

{include file="_footer.tpl"}

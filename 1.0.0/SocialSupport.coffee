###*
共有
###
module.exports = class SocialSupport
  V=1.1
  @LINE:0
  @TWITTER:1
  @FACEBOOK:2
  @SINAWEIBO:3

  constructor:->
    
  _openIntent= (sendstring,image)->
            intent = Ti.Android.createIntent(
              action: Ti.Android.ACTION_SEND
              type: 'text/plain'
              #type: "image/jpg"
            )
            intent.putExtra Ti.Android.EXTRA_TEXT, sendstring#text+" "+url+" "+_HASH_TAG
            #intent.putExtra Ti.Android.EXTRA_SUBJECT, subject
            #file = @Const.blobToFile image
            #intent.putExtraUri Ti.Android.EXTRA_STREAM,file.resolve()
            Ti.Android.currentActivity.startActivity Ti.Android.createIntentChooser intent,L "whichApplication","which application"
            

  _callLineText = (linestr)=>
      linestr = encodeURIComponent linestr
      openstr = "line://msg/text/#{linestr}"
      if Ti.UI.iOS? 
        if Ti.Platform.canOpenURL openstr
 
          Ti.Platform.openURL openstr 
        else
          #TODO ストアでLINEダウンロードさせる
          Ti.Platform.openURL "http://line.naver.jp/R/msg/text/?#{linestr}"
      else
        Ti.Platform.openURL openstr 
  
  @openShare:(num=0,text="",image)=>
    if Ti.UI.iOS?
      _Social = require("dk.napp.social")
      sns_obj = 
        text: text
  
      sns_obj.image = image if image?
      alertmessage = L("serviceNotProvisioned","Servic No Provisioned")
      switch num
        when @TWITTER
          if _Social.isTwitterSupported() then _Social.twitter sns_obj
          else alert "Twitter:#{alertmessage}"
        
  @postDialogShow:(text="",url,image,line=on)=>
    if Ti.UI.iOS?
      _Social = require("dk.napp.social")
      #ダイアログ出す
      LINE = 0
      TWITTER = 1
      FACEBOOK = 2
      SINAWEIBO = 3
      options = []
      
      #LINEをぷっしゅ
      options[LINE] = "LINE"
      
      #SNSに対応していれば、プッシュ
      
      options[TWITTER] = "Twitter"  #if Social.isTwitterSupported()
      options[FACEBOOK] = "Facebook"  #if Social.isFacebookSupported()
      options[SINAWEIBO] = L "SinaWeibo","SinaWeibo"  #if Social.isSinaWeiboSupported()
      options.push L("cancel","cancel")
      cancelnum = options.length-1
      dialog = Ti.UI.createOptionDialog
        cancel: cancelnum
        options: options
        title: L "choose_account_label","choose account label"
        message: L "choose_account_label","choose account label"
        
      dialog.addEventListener "click", (e) =>
        e_index = e.index
        return if e_index is cancelnum

        sns_obj = 
          text: text

        sns_obj.url = url if url?
        sns_obj.image = image if image?
        alertmessage = L("serviceNotProvisioned","Servic No Provisioned")

        
        #画像をとりあえずtmpに保存する
        switch e_index
          when LINE
            _callLineText text
          when TWITTER
            if _Social.isTwitterSupported() then _Social.twitter sns_obj
            else alert "Twitter:#{alertmessage}"
          when FACEBOOK
            if _Social.isFacebookSupported() then _Social.facebook sns_obj
            else alert "Facebook:#{alertmessage}"
          when SINAWEIBO
            if _Social.isSinaWeiboSupported() then _Social.sinaweibo sns_obj
            else alert "#{options[SINAWEIBO]}:#{alertmessage}"
      dialog.show() 
    else if Ti.Android?
      #インテント連携
      
      LINE = 0
      OTHER = 1
      sendstring = "#{text} #{url}"
      if line
        dialog = Ti.UI.createOptionDialog 
          options: [ 
            "LINE"
            L("more_item_label","other")
            L("cancel")
          ]
          cancel: 1
          title: L "choose_account_label","account"
        dialog.addEventListener 'click', (e)=> 
          e_index = e.index
          switch e_index
            when LINE then _callLineText sendstring
            when OTHER then _openIntent sendstring
              # #TODO activity開く
              # intent = Ti.Android.createIntent(
                # action: Ti.Android.ACTION_SEND
                # type: 'text/plain'
                # #type: "image/jpg"
              # )
              # intent.putExtra Ti.Android.EXTRA_TEXT, sendstring#text+" "+url+" "+_HASH_TAG
              # #intent.putExtra Ti.Android.EXTRA_SUBJECT, subject
              # #file = @Const.blobToFile image
              # #intent.putExtraUri Ti.Android.EXTRA_STREAM,file.resolve()
              # Ti.Android.currentActivity.startActivity Ti.Android.createIntentChooser intent,L "whichApplication","which application"
              
        dialog.show()
      else _openIntent sendstring
         
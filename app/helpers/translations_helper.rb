module TranslationsHelper
  TRANSLATIONS = {
    email_address:  { "🇺🇸": "Enter your email address", "🇪🇸": "Introduce tu correo electrónico", "🇫🇷": "Entrez votre adresse courriel", "🇮🇳": "अपना ईमेल पता दर्ज करें", "🇩🇪": "Geben Sie Ihre E-Mail-Adresse ein" },
    password: { "🇺🇸": "Enter your password", "🇪🇸": "Introduce tu contraseña", "🇫🇷": "Saisissez votre mot de passe", "🇮🇳": "अपना पासवर्ड दर्ज करें", "🇩🇪": "Geben Sie Ihr Passwort ein" },
    update_password: { "🇺🇸": "Change password", "🇪🇸": "Cambiar contraseña", "🇫🇷": "Changer le mot de passe", "🇮🇳": "पासवर्ड बदलें", "🇩🇪": "Passwort ändern" },
    user_name: { "🇺🇸": "Enter your name", "🇪🇸": "Introduce tu nombre", "🇫🇷": "Entrez votre nom", "🇮🇳": "अपना नाम दर्ज करें", "🇩🇪": "Geben Sie Ihren Namen ein" },
    account_name: { "🇺🇸": "Name this account", "🇪🇸": "Nombre de esta cuenta", "🇫🇷": "Nommez ce compte", "🇮🇳": "इस खाते का नाम दें", "🇩🇪": "Benennen Sie dieses Konto" },
    room_name: { "🇺🇸": "Name the room", "🇪🇸": "Nombrar la sala", "🇫🇷": "Nommez la salle", "🇮🇳": "कमरे का नाम दें", "🇩🇪": "Geben Sie dem Raum einen Namen" },
    invite_message: { "🇺🇸": "Welcome to Campfire. To invite some people to chat with you, share the join link below.", "🇪🇸": "Bienvenido a Campfire. Para invitar a algunas personas a chatear contigo, comparte el enlace de unión que se encuentra a continuación.", "🇫🇷": "Bienvenue sur Campfire. Pour inviter des personnes à discuter avec vous, partagez le lien pour rejoindre ci-dessous.", "🇮🇳": "Campfire में आपका स्वागत है। अधिक लोगों को चैट के लिए आमंत्रित करने के लिए, नीचे जुड़ने का लिंक साझा करें।", "🇩🇪": "Willkommen bei Campfire. Um einige Personen zum Chatten einzuladen, teilen Sie den unten stehenden Beitrittslink." },
    incompatible_browser_messsage: { "🇺🇸": "Upgrade to a supported web browser. Campfire requires a modern web browser. Please use one of the browsers listed below and make sure auto-updates are enabled.", "🇪🇸": "Actualiza a un navegador web compatible. Campfire requiere un navegador web moderno. Utiliza uno de los navegadores listados a continuación y asegúrate de que las actualizaciones automáticas estén habilitadas.", "🇫🇷": "Mettez à jour vers un navigateur web pris en charge. Campfire nécessite un navigateur web moderne. Veuillez utiliser l'un des navigateurs répertoriés ci-dessous et assurez-vous que les mises à jour automatiques sont activées.", "🇮🇳": "समर्थित वेब ब्राउज़र में अपग्रेड करें। Campfire को एक आधुनिक वेब ब्राउज़र की आवश्यकता है। कृपया नीचे सूचीबद्ध ब्राउज़रों में से कोई एक का उपयोग करें और सुनिश्चित करें कि स्वचालित अपडेट्स सक्षम हैं।", "🇩🇪": "Aktualisieren Sie auf einen unterstützten Webbrowser. Campfire erfordert einen modernen Webbrowser. Verwenden Sie bitte einen der unten aufgeführten Browser und stellen Sie sicher, dass automatische Updates aktiviert sind." },
    bio: { "🇺🇸": "Enter a few words about yourself.", "🇪🇸": "Ingresa algunas palabras sobre ti mismo.", "🇫🇷": "Saisissez quelques mots à propos de vous-même.", "🇮🇳": "अपने बारे में कुछ शब्द लिखें.", "🇩🇪": "Geben Sie ein paar Worte über sich selbst ein." }

  }

  def translations_for(translation_key)
    tag.dl(class: "language-list") do
      TRANSLATIONS[translation_key].map do |language, translation|
        concat tag.dt(language)
        concat tag.dd(translation, class: "margin-none")
      end
    end
  end

  def translation_button(translation_key)
    tag.details(class: "position-relative", data: { controller: "popup", action: "keydown.esc->popup#close toggle->popup#toggle click@document->popup#closeOnClickOutside", popup_orientation_top_class: "popup-orientation-top" }) do
      tag.summary(class: "btn", tabindex: -1) do
        concat image_tag("globe.svg", role: "presentation", class: "color-icon")
        concat tag.span("Translate", class: "for-screen-reader")
      end +
      tag.div(class: "lanuage-list-menu shadow", data: { popup_target: "menu" }) do
        translations_for(translation_key)
      end
    end
  end
end

import 'package:flutter/widgets.dart';

/// App strings in English and Greek.
///
/// Each getter holds both translations side by side so a missing translation
/// is impossible. Widgets call [S.of] (which subscribes them to locale
/// changes); services without a context use [S.current].
class S {
  final String lang;
  const S._(this.lang);

  static const supportedLanguages = ['en', 'el'];
  static const _en = S._('en');
  static const _el = S._('el');

  static S current = _en;

  static S forLanguage(String code) => code == 'el' ? _el : _en;

  static S of(BuildContext context) =>
      forLanguage(Localizations.localeOf(context).languageCode);

  bool get isGreek => lang == 'el';
  String _v(String en, String el) => isGreek ? el : en;

  // ── General ────────────────────────────────────────────────────────────
  String get cancel => _v('Cancel', 'Ακύρωση');
  String get save => _v('Save', 'Αποθήκευση');
  String get add => _v('Add', 'Προσθήκη');
  String get delete => _v('Delete', 'Διαγραφή');
  String get done => _v('Done', 'Τέλος');
  String get edit => _v('Edit', 'Επεξεργασία');
  String get share => _v('Share', 'Κοινοποίηση');
  String get remove => _v('Remove', 'Αφαίρεση');
  String get create => _v('Create', 'Δημιουργία');
  String get continueLabel => _v('Continue', 'Συνέχεια');
  String get openSettings => _v('Open Settings', 'Άνοιγμα Ρυθμίσεων');

  // ── Home ───────────────────────────────────────────────────────────────
  String get tagline =>
      _v('Never forget a perfect gift', 'Μην ξεχάσεις ποτέ το τέλειο δώρο');
  String peopleCount(int n) => isGreek
      ? '$n ${n == 1 ? 'άτομο' : 'άτομα'}'
      : '$n ${n == 1 ? 'person' : 'people'}';
  String get upcomingBirthdays =>
      _v('Upcoming Birthdays!', 'Επερχόμενα Γενέθλια!');
  String get today => _v('Today! 🎉', 'Σήμερα! 🎉');
  String get tomorrow => _v('Tomorrow!', 'Αύριο!');
  String inDays(int n) => _v('in $n days', 'σε $n μέρες');
  String get searchPeople => _v('Search people...', 'Αναζήτηση ατόμων...');
  String get noOneFound => _v('No one found', 'Δεν βρέθηκε κανείς');
  String get tryDifferentName =>
      _v('Try a different name', 'Δοκίμασε άλλο όνομα');
  String get addFirstPerson =>
      _v('Add your first person!', 'Πρόσθεσε το πρώτο σου άτομο!');
  String get tapToStart => _v('Tap the button below to get started',
      'Πάτησε το κουμπί παρακάτω για να ξεκινήσεις');
  String ideasCount(int n) => isGreek
      ? '$n ${n == 1 ? 'ιδέα' : 'ιδέες'}'
      : '$n idea${n == 1 ? '' : 's'}';
  String get cardToday => _v('🎉 Today!', '🎉 Σήμερα!');
  String get cardTomorrow => _v('🎂 Tomorrow', '🎂 Αύριο');
  String cardInDays(int n) => _v('🎂 in $n days', '🎂 σε $n μέρες');
  String get addPersonTitle => _v('Add a person', 'Προσθήκη ατόμου');
  String get addManually => _v('Add manually', 'Χειροκίνητη προσθήκη');
  String get addManuallySub => _v('Type in their name and birthday',
      'Γράψε το όνομα και τα γενέθλιά τους');
  String get importFromContacts =>
      _v('Import from Contacts', 'Εισαγωγή από Επαφές');
  String get importFromContactsSub => _v(
      'Pick people from your phone — birthdays come along automatically',
      'Διάλεξε άτομα από το κινητό σου — τα γενέθλια έρχονται αυτόματα');
  String peopleAdded(int n) => isGreek
      ? (n == 1 ? 'Προστέθηκε 1 άτομο' : 'Προστέθηκαν $n άτομα')
      : (n == 1 ? '1 person added' : '$n people added');

  // ── Person form ────────────────────────────────────────────────────────
  String get editPerson => _v('Edit Person', 'Επεξεργασία Ατόμου');
  String get addNewPerson => _v('Add New Person', 'Νέο Άτομο');
  String get choosePhotoOrEmoji =>
      _v('Change avatar', 'Αλλαγή εικόνας προφίλ');
  String get nameRequiredLabel => _v('Name *', 'Όνομα *');
  String get nameHint =>
      _v('e.g. Mom, Best Friend, John...', 'π.χ. Μαμά, Κολλητός, Γιάννης...');
  String get nameRequired => _v('Name is required', 'Το όνομα είναι υποχρεωτικό');
  String get birthdayOptional =>
      _v('Birthday (optional)', 'Γενέθλια (προαιρετικό)');
  String get selectBirthday => _v('Select birthday', 'Επίλεξε γενέθλια');
  String get reminderInfo => _v(
      'You\'ll get a reminder 7 days before and on the day, at 9:00.',
      'Θα λάβεις υπενθύμιση 7 μέρες πριν και την ημέρα των γενεθλίων, στις 9:00.');
  String get notesOptional => _v('Notes (optional)', 'Σημειώσεις (προαιρετικό)');
  String get notesHint => _v('Their interests, style, preferences...',
      'Ενδιαφέροντα, στυλ, προτιμήσεις...');
  String get saveChanges => _v('✓ Save Changes', '✓ Αποθήκευση Αλλαγών');
  String get addPersonButton => _v('+ Add Person', '+ Προσθήκη Ατόμου');
  String get avatar => _v('Avatar', 'Εικόνα προφίλ');
  String get chooseEmoji => _v('Choose an emoji', 'Διάλεξε emoji');
  String get chooseFromPhotos =>
      _v('Choose from Photos', 'Επιλογή από Φωτογραφίες');
  String get takePhoto => _v('Take a photo', 'Λήψη φωτογραφίας');
  String get removePhoto => _v('Remove photo', 'Αφαίρεση φωτογραφίας');
  String get cardBackground => _v('Card background', 'Φόντο κάρτας');
  String get cardBackgroundSub => _v('Optional — a photo behind their card',
      'Προαιρετικό — μια φωτογραφία πίσω από την κάρτα');
  String get addBackground => _v('Add background', 'Προσθήκη φόντου');
  String get changeBackground => _v('Change', 'Αλλαγή');
  String get photoError => _v('Could not load that photo.',
      'Δεν ήταν δυνατή η φόρτωση της φωτογραφίας.');

  // ── Birthday picker ────────────────────────────────────────────────────
  String get birthdayPickerTitle => _v('Birthday', 'Γενέθλια');
  String get dontKnowYear =>
      _v('I don\'t know the year', 'Δεν ξέρω τη χρονιά');
  String get day => _v('Day', 'Ημέρα');
  String get month => _v('Month', 'Μήνας');
  String get year => _v('Year', 'Έτος');
  String turnsAge(int age) => _v('turns $age', 'γίνεται $age');
  String get clearBirthday => _v('Clear', 'Καθαρισμός');

  // ── Person detail ──────────────────────────────────────────────────────
  String get deletePersonTitle => _v('Delete Person?', 'Διαγραφή Ατόμου;');
  String deletePersonBody(String name) => _v(
      'This will remove $name and all their gift ideas.',
      'Θα διαγραφεί ο/η $name και όλες οι ιδέες δώρων.');
  String daysAway(int n) => n == 0
      ? _v('today!', 'σήμερα!')
      : n == 1
          ? _v('tomorrow', 'αύριο')
          : _v('$n days away', 'σε $n μέρες');
  String ideasStat(int n) => _v('$n ideas', '$n ιδέες');
  String boughtStat(int n) => _v('$n bought', '$n αγορασμένα');
  String get soon => _v('Soon! 🎉', 'Σύντομα! 🎉');
  String get giftIdeas => _v('Gift Ideas', 'Ιδέες Δώρων');
  String get addIdea => _v('Add Idea', 'Νέα Ιδέα');
  String get noGiftIdeas => _v('No gift ideas yet!', 'Δεν υπάρχουν ιδέες ακόμα!');
  String noGiftIdeasSub(String name) => _v(
      'Tap "Add Idea" to save gift ideas for $name',
      'Πάτησε «Νέα Ιδέα» για να αποθηκεύσεις ιδέες δώρων για τον/την $name');
  String get addGiftIdea => _v('Add Gift Idea', 'Νέα Ιδέα Δώρου');
  String get link => _v('Link', 'Σύνδεσμος');

  // ── Gift form ──────────────────────────────────────────────────────────
  String get editGiftIdea => _v('Edit Gift Idea', 'Επεξεργασία Ιδέας');
  String get newGiftIdea => _v('New Gift Idea', 'Νέα Ιδέα Δώρου');
  String get giftNameLabel => _v('Gift name *', 'Όνομα δώρου *');
  String get giftNameHint => _v('e.g. Wireless headphones, Book, Perfume...',
      'π.χ. Ασύρματα ακουστικά, Βιβλίο, Άρωμα...');
  String get category => _v('Category', 'Κατηγορία');
  String get selectCategory => _v('Select a category', 'Επίλεξε κατηγορία');
  String get createCategory =>
      _v('➕ Create new category…', '➕ Νέα κατηγορία…');
  String get newCategory => _v('New category', 'Νέα κατηγορία');
  String get categoryName => _v('Category name', 'Όνομα κατηγορίας');
  String get categoryNameHint =>
      _v('e.g. Board games', 'π.χ. Επιτραπέζια');
  String get categoryExists => _v('That category already exists',
      'Αυτή η κατηγορία υπάρχει ήδη');
  String get description => _v('Description', 'Περιγραφή');
  String get descriptionHint => _v('Notes, details, size, color preferences...',
      'Σημειώσεις, λεπτομέρειες, μέγεθος, χρώμα...');
  String get estimatedPrice => _v('Estimated price', 'Εκτιμώμενη τιμή');
  String get onlineLink => _v('Online link', 'Σύνδεσμος καταστήματος');
  String get invalidUrl => _v('Please enter a valid URL (include https://)',
      'Γράψε έγκυρο σύνδεσμο (με https://)');
  String get storeName => _v('Store / Shop name', 'Κατάστημα');
  String get storeNameHint => _v('e.g. Amazon, Zara, Local bookstore...',
      'π.χ. Amazon, Zara, βιβλιοπωλείο της γειτονιάς...');
  String get storeLocation =>
      _v('Store location / Address', 'Τοποθεσία / Διεύθυνση');
  String get storeLocationHint => _v('e.g. City Centre Mall, Floor 2...',
      'π.χ. Εμπορικό κέντρο, 2ος όροφος...');
  String get markPurchased => _v('Mark as purchased', 'Σήμανση ως αγορασμένο');
  String get markPurchasedSub => _v('Check this off once you\'ve bought it',
      'Τσέκαρέ το όταν το αγοράσεις');
  String get addGiftButton => _v('+ Add Gift Idea', '+ Προσθήκη Ιδέας');

  // ── Settings ───────────────────────────────────────────────────────────
  String get settings => _v('Settings', 'Ρυθμίσεις');
  String get general => _v('General', 'Γενικά');
  String get language => _v('Language', 'Γλώσσα');
  String get languageName => _v('English', 'Ελληνικά');
  String get categories => _v('Gift categories', 'Κατηγορίες δώρων');
  String get manageCategories =>
      _v('Your custom categories', 'Οι δικές σου κατηγορίες');
  String get noCustomCategories => _v(
      'No custom categories yet. Create one here or while adding a gift idea.',
      'Δεν υπάρχουν δικές σου κατηγορίες ακόμα. Δημιούργησε μία εδώ ή όταν προσθέτεις ιδέα δώρου.');
  String get sharing => _v('Sharing', 'Κοινοποίηση');
  String get importSharedCard =>
      _v('Import a shared card', 'Εισαγωγή κοινοποιημένης κάρτας');
  String get importSharedCardSub => _v('Paste a GiftLoop link you received',
      'Επικόλλησε έναν σύνδεσμο GiftLoop που έλαβες');
  String get pasteLink => _v('Paste link', 'Επικόλληση συνδέσμου');
  String get invalidShareLink => _v(
      'That doesn\'t look like a GiftLoop share link.',
      'Αυτός δεν μοιάζει με σύνδεσμο κοινοποίησης GiftLoop.');
  String get about => _v('About', 'Σχετικά');
  String get aboutGiftLoop => _v('About GiftLoop', 'Σχετικά με το GiftLoop');
  String version(String v) => _v('Version $v', 'Έκδοση $v');

  // ── About ──────────────────────────────────────────────────────────────
  String get aboutWhatTitle => _v('What is GiftLoop?', 'Τι είναι το GiftLoop;');
  String get aboutWhatBody => _v(
      'GiftLoop is a little notebook for gift ideas. Whenever you hear a '
          'friend say "I\'d love one of those", save it to their card — with a '
          'price, a link or the shop where you saw it.',
      'Το GiftLoop είναι ένα μικρό σημειωματάριο για ιδέες δώρων. Όταν '
          'ακούσεις κάποιον αγαπημένο σου να λέει «αυτό θα το ήθελα», '
          'αποθήκευσέ το στην κάρτα του — με τιμή, σύνδεσμο ή το κατάστημα '
          'όπου το είδες.');
  String get aboutWhyTitle => _v('Why it exists', 'Γιατί υπάρχει');
  String get aboutWhyBody => _v(
      'Good gift ideas come at random moments and are forgotten by the time a '
          'birthday arrives. GiftLoop keeps them in one place and reminds you a '
          'week before each birthday, so you always have something thoughtful '
          'ready. You can also share a person\'s card with family or friends to '
          'plan gifts together.',
      'Οι καλές ιδέες για δώρα έρχονται σε τυχαίες στιγμές και ξεχνιούνται '
          'μέχρι να έρθουν τα γενέθλια. Το GiftLoop τις κρατά σε ένα μέρος και '
          'σου θυμίζει μία εβδομάδα πριν από κάθε γενέθλια, ώστε να έχεις πάντα '
          'κάτι ξεχωριστό έτοιμο. Μπορείς επίσης να μοιραστείς την κάρτα ενός '
          'ατόμου με οικογένεια ή φίλους για να οργανώσετε δώρα μαζί.');
  String get aboutPrivacyTitle => _v('Your data stays yours', 'Τα δεδομένα σου μένουν δικά σου');
  String get aboutPrivacyBody => _v(
      'Everything is stored only on this device. GiftLoop has no account, no '
          'servers and no tracking. Contacts and photos are read only when you '
          'choose to import them.',
      'Όλα αποθηκεύονται μόνο σε αυτή τη συσκευή. Το GiftLoop δεν έχει '
          'λογαριασμούς, διακομιστές ή παρακολούθηση. Οι επαφές και οι '
          'φωτογραφίες διαβάζονται μόνο όταν επιλέξεις να τις εισαγάγεις.');
  String get madeWithLove =>
      _v('Made with ❤️ for thoughtful gift-givers',
          'Φτιαγμένο με ❤️ για όσους σκέφτονται τα δώρα τους');

  /// Text before the "KV TecHub" link on the second line.
  String get madeByPrefix => _v('by ', 'από την ');

  // ── Contacts import ────────────────────────────────────────────────────
  String get contactsTitle => _v('Import from Contacts', 'Εισαγωγή από Επαφές');
  String get searchContacts => _v('Search contacts...', 'Αναζήτηση επαφών...');
  String get contactsDenied => _v(
      'GiftLoop needs access to your contacts to import people. You can allow it in Settings.',
      'Το GiftLoop χρειάζεται πρόσβαση στις επαφές σου για να εισαγάγει άτομα. Μπορείς να την επιτρέψεις από τις Ρυθμίσεις.');
  String get contactsLimited => _v(
      'You\'ve shared only some contacts with GiftLoop. Change this in Settings to see more.',
      'Έχεις μοιραστεί μόνο κάποιες επαφές με το GiftLoop. Άλλαξέ το από τις Ρυθμίσεις για να δεις περισσότερες.');
  String get noContacts => _v('No contacts found', 'Δεν βρέθηκαν επαφές');
  String get alreadyAdded => _v('Already in GiftLoop', 'Υπάρχει ήδη');
  String get noBirthdaySaved =>
      _v('No birthday saved', 'Χωρίς αποθηκευμένα γενέθλια');
  String get selectWithBirthdays =>
      _v('Select all with birthdays', 'Επιλογή όσων έχουν γενέθλια');
  String get clearSelection => _v('Clear selection', 'Καθαρισμός επιλογής');
  String addNPeople(int n) => isGreek
      ? (n == 1 ? 'Προσθήκη 1 ατόμου' : 'Προσθήκη $n ατόμων')
      : (n == 1 ? 'Add 1 person' : 'Add $n people');

  // ── Sharing (sender) ───────────────────────────────────────────────────
  String shareTitle(String name) =>
      _v('Share $name\'s card', 'Κοινοποίηση κάρτας: $name');
  String get shareIntro => _v(
      'Choose which gift ideas to send. The receiver can add them as a new person or merge them into someone they already have.',
      'Διάλεξε ποιες ιδέες δώρων θα στείλεις. Ο παραλήπτης μπορεί να τις προσθέσει ως νέο άτομο ή να τις συγχωνεύσει με κάποιον που ήδη έχει.');
  String get includeBirthday => _v('Include birthday', 'Συμπερίληψη γενεθλίων');
  String get includeNotes => _v('Include notes', 'Συμπερίληψη σημειώσεων');
  String get selectAll => _v('Select all', 'Επιλογή όλων');
  String get selectNone => _v('Select none', 'Καμία επιλογή');
  String shareNGifts(int n) => isGreek
      ? (n == 1 ? 'Κοινοποίηση 1 ιδέας' : 'Κοινοποίηση $n ιδεών')
      : (n == 1 ? 'Share 1 gift idea' : 'Share $n gift ideas');
  String get shareCardOnly => _v('Share card', 'Κοινοποίηση κάρτας');
  String get shareHint => _v(
      'Send it with Messages, WhatsApp, AirDrop (Bluetooth) or any app.',
      'Στείλ\' το με Μηνύματα, WhatsApp, AirDrop (Bluetooth) ή οποιαδήποτε εφαρμογή.');
  String shareMessage(String name, String link) => _v(
      '🎁 Here are gift ideas for $name from GiftLoop. Tap to open them in the app '
          '(it will take you to the App Store if you don\'t have it yet):\n$link',
      '🎁 Ιδέες δώρων για $name από το GiftLoop. Πάτησε για να τις ανοίξεις στην εφαρμογή '
          '(θα σε μεταφέρει στο App Store αν δεν την έχεις ακόμα):\n$link');
  String shareSubject(String name) =>
      _v('Gift ideas for $name', 'Ιδέες δώρων για $name');

  // ── Sharing (receiver) ─────────────────────────────────────────────────
  String get receivedCard => _v('Shared card', 'Κοινοποιημένη κάρτα');
  String receivedIntro(String name, int n) => isGreek
      ? 'Έλαβες ${n == 1 ? '1 ιδέα δώρου' : '$n ιδέες δώρων'} για τον/την $name.'
      : 'You received ${n == 1 ? '1 gift idea' : '$n gift ideas'} for $name.';
  String get isThisNew => _v('Who is this person for you?',
      'Ποιο είναι αυτό το άτομο για εσένα;');
  String get newPersonOption => _v('A new person', 'Νέο άτομο');
  String get newPersonOptionSub => _v('Create a new card with these gift ideas',
      'Δημιουργία νέας κάρτας με αυτές τις ιδέες');
  String get existingPersonOption =>
      _v('Someone I already have', 'Κάποιος που ήδη έχω');
  String get existingPersonOptionSub => _v(
      'Merge these gift ideas into their card',
      'Συγχώνευση των ιδεών στην κάρτα του');
  String get choosePerson => _v('Choose the person', 'Επίλεξε το άτομο');
  String get likelyMatch => _v('Same name', 'Ίδιο όνομα');
  String get importAsNew => _v('Add as new person', 'Προσθήκη ως νέο άτομο');
  String get mergeInto => _v('Merge gift ideas', 'Συγχώνευση ιδεών');
  String importedNew(String name) =>
      _v('$name was added 🎉', 'Προστέθηκε: $name 🎉');
  String merged(int added, String name) => isGreek
      ? (added == 0
          ? 'Ο/Η $name είχε ήδη όλες αυτές τις ιδέες'
          : 'Προστέθηκαν $added ${added == 1 ? 'ιδέα' : 'ιδέες'} στον/στην $name')
      : (added == 0
          ? '$name already had all of these ideas'
          : 'Added $added ${added == 1 ? 'idea' : 'ideas'} to $name');
  String get noPeopleYet =>
      _v('You have no people yet.', 'Δεν έχεις κανένα άτομο ακόμα.');

  // ── Notifications ──────────────────────────────────────────────────────
  String notifWeekTitle(String name) => _v(
      '🎁 $name\'s birthday is in one week!',
      '🎁 Τα γενέθλια του/της $name είναι σε μία εβδομάδα!');
  String notifWeekBody(int ideas) => ideas == 0
      ? _v('Time to think of a gift! Open GiftLoop to add some ideas.',
          'Ώρα να σκεφτείς ένα δώρο! Άνοιξε το GiftLoop για να προσθέσεις ιδέες.')
      : _v(
          'Time to get a gift! You have $ideas gift idea${ideas == 1 ? '' : 's'} saved.',
          'Ώρα για δώρο! Έχεις $ideas ${ideas == 1 ? 'αποθηκευμένη ιδέα' : 'αποθηκευμένες ιδέες'}.');
  String notifDayTitle(String name) => _v(
      '🎂 It\'s $name\'s birthday today!', '🎂 Σήμερα έχει γενέθλια ο/η $name!');
  String get notifDayBody =>
      _v('Don\'t forget to wish them a happy birthday 🎉',
          'Μην ξεχάσεις να ευχηθείς χρόνια πολλά 🎉');
  String get notifChannelName => _v('Birthday Reminders', 'Υπενθυμίσεις γενεθλίων');
  String get notifChannelDesc =>
      _v('Reminds you before a birthday', 'Σου θυμίζει πριν από γενέθλια');

  // ── Built-in categories ────────────────────────────────────────────────
  static const _categoryGreek = {
    '🎮 Tech & Gaming': '🎮 Τεχνολογία & Gaming',
    '👗 Fashion & Style': '👗 Μόδα & Στυλ',
    '📚 Books & Education': '📚 Βιβλία & Εκπαίδευση',
    '🍫 Food & Treats': '🍫 Φαγητό & Λιχουδιές',
    '🌿 Health & Wellness': '🌿 Υγεία & Ευεξία',
    '🎨 Arts & Crafts': '🎨 Τέχνες & Χειροτεχνίες',
    '🏠 Home & Living': '🏠 Σπίτι & Διαβίωση',
    '⚽ Sports & Outdoor': '⚽ Αθλητισμός & Ύπαιθρος',
    '💎 Jewelry & Accessories': '💎 Κοσμήματα & Αξεσουάρ',
    '🎭 Experiences': '🎭 Εμπειρίες',
    '🧸 Toys & Fun': '🧸 Παιχνίδια & Διασκέδαση',
    '✈️ Travel': '✈️ Ταξίδια',
    '🎵 Music & Entertainment': '🎵 Μουσική & Ψυχαγωγία',
    '💻 Software & Subscriptions': '💻 Λογισμικό & Συνδρομές',
    '🌸 Other': '🌸 Άλλο',
  };

  /// Built-in categories are stored by their English label; this shows them
  /// in the current language. Custom categories are shown as typed.
  String categoryLabel(String stored) =>
      isGreek ? (_categoryGreek[stored] ?? stored) : stored;
}

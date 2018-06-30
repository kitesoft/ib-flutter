
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ib/IBDateTime.dart';

class IBLocalStringTuple<String> {
  String type; String value;
  IBLocalStringTuple({this.type, this.value});
}

class IBLocalString {

  static BuildContext context;
  static Locale locale = Localizations.localeOf(context);

  // UTIL
  static var codeLanguage = locale.languageCode;
  static var isSpanish = locale.languageCode.contains("es");
  static get nowTimestamp => DateTime.now().millisecondsSinceEpoch/1000;

  // EVENT
  // ...
  // ...
  static String get eventActionEdit {
    return isSpanish ? "Editar" : "Edit";
  }

  static String get eventActionFollowing {
    return isSpanish ? "Interesado" : "Interested";
  }

  static String get eventEnded {
    return isSpanish ? "Terminado" : "Finished";
  }

  static String get eventFollowedBy {
    return isSpanish ? "Interesados:" : "Interested:";
  }

  static String eventGroup(String name) {
    return isSpanish ? "Para $name" : "For $name";
  }

  static String eventMessageFollower(String nameUser, String codeLocale) {
    return codeLocale.contains("es") ? "$nameUser esta interesado" : "$nameUser is interested";
  }

  static String get eventNoFollowers {
    return isSpanish ? "Sin interesados todavia" : "No interested yet";
  }

  static String eventFollowersCount(int count) {
    return isSpanish ? "$count ${count == 1 ? "seguidor" : "seguidores"}" : "$count ${count == 1 ? "follower" : "followers"}";
  }

  static String eventFormatTimestampEnd(double timestamp) {

    var date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt()*1000);
    var compareToDate = DateTime.now();

    if (date.millisecondsSinceEpoch < 0.0) {
      return "";
    }

    var compareToDateIn = compareToDate ?? DateTime.now();
    var isFuture = compareToDateIn.isBefore(date);

    var beforeDate = date.isBefore(compareToDateIn) ? date : compareToDateIn;
    var afterDate = beforeDate == date ? compareToDateIn : date;

    var diff = afterDate.difference(beforeDate);
    var daysDiff = IBDateTime.dayDifference(afterDate, beforeDate);

    if (isFuture) {
      if (daysDiff > 6) {
        String format =  DateFormat.yMMMMd().add_jm().format(date);
        return isSpanish ? "a $format" : "to $format";
      }
      // six days or sooner
      if (daysDiff > 1) {
        var format = DateFormat.E().add_jm().format(date);
        return isSpanish ? "al siguiente $format" : "to next $format";
      }
      // yest or sooner
      if (daysDiff > 0) {
        var hourFormat = DateFormat.jm().format(date);
        return isSpanish ? "a manaña $hourFormat" : "to tomorrow $hourFormat";
      }
      // today
      if (diff.inHours > 0) {
        var hourFormat = DateFormat.jm().format(date);
        return isSpanish ? "a las $hourFormat" : "to $hourFormat";
      }
      // this hour
      var diffMinutes = diff.inMinutes;
      if (diffMinutes > 0) {
        return isSpanish ? "a $diffMinutes ${diffMinutes == 1 ? "" : isSpanish ? "minuto" : "minutos"}" : "to $diffMinutes ${diffMinutes == 1 ? "" : isSpanish ? "minute" : "minutes"}";
      }
      // this minute
      return isSpanish ? "a menos de un minuto" : "to less than a minute";
    }

    if (daysDiff > 6) {
      String format =  DateFormat.yMMMMd().add_jm().format(date);
      return format;
    }
    // six days or sooner
    if (daysDiff > 1) {
      var format = DateFormat.E().add_jm().format(date);
      return isSpanish ? "al pasado $format" : "to last $format";
    }
    // yest or sooner
    if (daysDiff > 0) {
      var hourFormat = DateFormat.jm().format(date);
      return isSpanish ? "a ayer $hourFormat" : "to yesterday $hourFormat";
    }
    // today
    if (diff.inHours > 0) {
      var hourFormat = DateFormat.jm().format(date);
      return hourFormat;
    }
    // this hour
    var diffMinutes = diff.inMinutes;
    if (diffMinutes > 0) {
      return isSpanish ? "a hace $diffMinutes ${diffMinutes == 1 ? "" : isSpanish ? "minuto" : "minutos"}" : "to $diffMinutes ${diffMinutes == 1 ? "" : isSpanish ? "minute" : "minutes"} ago";
    }
    // this minute
    return isSpanish ? "a hace menos de un minuto" : "to less than a minute ago";
  }

  static String eventFormatTimestampStart(double timestamp) {

    var date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt()*1000);
    var compareToDate = DateTime.now();

    if (date.millisecondsSinceEpoch < 0.0) {
      return "";
    }

    var compareToDateIn = compareToDate ?? DateTime.now();
    var isFuture = compareToDateIn.isBefore(date);

    var beforeDate = date.isBefore(compareToDateIn) ? date : compareToDateIn;
    var afterDate = beforeDate == date ? compareToDateIn : date;

    var diff = afterDate.difference(beforeDate);
    var daysDiff = IBDateTime.dayDifference(afterDate, beforeDate);

    if (isFuture) {
      if (daysDiff > 6) {
        String format =  DateFormat.yMMMMd().add_jm().format(date);
        return isSpanish ? "Del $format" : "From $format";
      }
      // six days or sooner
      if (daysDiff > 1) {
        var format = DateFormat.E().add_jm().format(date);
        return isSpanish ? "Del siguiente $format" : "From next $format";
      }
      // yest or sooner
      if (daysDiff > 0) {
        var hourFormat = DateFormat.jm().format(date);
        return isSpanish ? "De manaña $hourFormat" : "From tomorrow $hourFormat";
      }
      // today
      if (diff.inHours > 0) {
        var hourFormat = DateFormat.jm().format(date);
        return isSpanish ? "De las $hourFormat" : "From $hourFormat";
      }
      // this hour
      var diffMinutes = diff.inMinutes;
      if (diffMinutes > 0) {
        return isSpanish ? "En $diffMinutes ${diffMinutes == 1 ? "" : isSpanish ? "minuto" : "minutos"}" : "In $diffMinutes ${diffMinutes == 1 ? "" : isSpanish ? "minute" : "minutes"}";
      }
      // this minute
      return isSpanish ? "En menos de un minuto" : "In less than a minute";
    }

    if (daysDiff > 6) {
      String format =  DateFormat.yMMMMd().add_jm().format(date);
      return format;
    }
    // six days or sooner
    if (daysDiff > 1) {
      var format = DateFormat.E().add_jm().format(date);
      return isSpanish ? "Del pasado $format" : "From last $format";
    }
    // yest or sooner
    if (daysDiff > 0) {
      var hourFormat = DateFormat.jm().format(date);
      return isSpanish ? "De ayer $hourFormat" : "From yesterday $hourFormat";
    }
    // today
    if (diff.inHours > 0) {
      var hourFormat = DateFormat.jm().format(date);
      return hourFormat;
    }
    // this hour
    var diffMinutes = diff.inMinutes;
    if (diffMinutes > 0) {
      return isSpanish ? "Hace $diffMinutes ${diffMinutes == 1 ? "" : isSpanish ? "minuto" : "minutos"}" : "In $diffMinutes ${diffMinutes == 1 ? "" : isSpanish ? "minute" : "minutes"} ago";
    }
    // this minute
    return isSpanish ? "Hace menos de un minuto" : "In less than a minute ago";
  }

  static String eventMoreFollowersCount(int count) {
    return isSpanish ? "y $count más" : "and $count more";
  }

  static String get eventNow {
    return isSpanish ? "Ahora" : "Now";
  }

  static String get eventOrganizedBy {
    return isSpanish ? "Organizado por" : "Organized by";
  }

  static String get eventReport {
    return isSpanish ? "Reportar" : "Report";
  }

  static String get eventToday {
    return isSpanish ? "Hoy" : "Today";
  }


  // EVENT CREATE
  // ...
  // ...
  static String get eventsLocationEnable {
    return isSpanish ? "Authoriza tu ubicacion para mostrarte eventos cerca de ti" : "Enable your location to discover events nearby";
  }

  static String eventsNewCount(int count) {
    return isSpanish ? "$count nuevos" : "$count new";
  }

  static String get eventsTitle {
    return "Icebreak";
  }

  // EVENT CREATE
  // ...
  // ...
  static String get eventCreate {
    return isSpanish ? "Crear" : "Create";
  }

  static String get eventCreateEdit {
    return isSpanish ? "Listo" : "Done";
  }

  static String get eventCreateEnds {
    return isSpanish ? "Termina:" : "Ends:";
  }

  static String eventCreateGroup({String name}) {
    return isSpanish ? "Para $name" : "For $name";
  }

  static String get eventCreateEveryone {
    return isSpanish ? "Todos" : "Everyone";
  }

  static String eventCreateFormatDay(DateTime futureDate) {
    var days = IBDateTime.dayDifference(futureDate, DateTime.now());
    if (days == 0) {
      return isSpanish ? "Hoy" : "Today";
    }
    if (days == 1) {
      return isSpanish ? "Mañana" : "Tomorrow";
    }
    if (days < 7) {
      return DateFormat.EEEE().format(futureDate);
    }
    return DateFormat.yMMMMd().format(futureDate);
  }

  static String get eventCreateGroupCreate {
    return isSpanish ? "Crear grupo" : "Create group";
  }

  static String get eventCreateHintDescription {
    return isSpanish ? "Escribe la descripción del evento" : "Type event's description";
  }

  static String eventCreateMessagePlaceFollower(String namePlace, String codeLocale) {
    return codeLocale.contains("es") ? "Nuevo evento de $namePlace" : "New event in $namePlace";
  }

  static String eventCreateMessageEditUserFollower(String codeLocale) {
    return codeLocale.contains("es") ? "El evento ha sido cambiado" : "Event has been changed";
  }

  static String eventCreateMessageUserFollower(String nameUser, String codeLocale) {
    return codeLocale.contains("es") ? "Nuevo evento de $nameUser" : "New event by $nameUser";
  }

  static String get eventCreatePublic {
    return isSpanish ? "Evento para todos" : "Event for everyone";
  }

  static String get eventCreateSelectDay {
    return isSpanish ? "Selecciona el día" : "Select day";
  }

  static String get eventCreateSelectPlace {
    return isSpanish ? "Busca el lugar" : "Search place";
  }

  static String get eventCreateSelectTimeOfDay {
    return isSpanish ? "Seleccion la hora " : "Select hour";
  }

  static String get eventCreateStarts {
    return isSpanish ? "Empieza:" : "Starts:";
  }

  static String get eventCreateTitle {
    return isSpanish ? "Crea Nuevo Evento" : "Create Event";
  }

  static String get eventCreateNameHint {
    return isSpanish ? "Escribe el nombre del evento" : "Type event's name";
  }

  static String get eventCreateWhen {
    return isSpanish ? "Donde?" : "When?";
  }

  static String get eventCreateWhere {
    return isSpanish ? "Cuándo?" : "Where?";
  }


  // GROUP
  // ...
  // ...
  static String get groupActionAddEvent {
    return isSpanish ? "Agregar evento" : "Add event";
  }

  static String get groupActionAddMembers {
    return isSpanish ? "Agregar miembros" : "Add members";
  }

  static String get groupActionEdit {
    return isSpanish ? "Editar" : "Edit";
  }

  static String get groupActionLeave {
    return isSpanish ? "Salir del grupo" : "Leave group";
  }

  static String groupEventsActiveCount(int count) {
    return isSpanish ? "$count ${count == 1 ? "evento" : "eventos"}" : "$count ${count == 1 ? "event" : "events"}";
  }

  static String groupEventsInactiveCount(int count) {
    return isSpanish ? "$count ${count == 1 ? "evento pasado" : "eventos pasados"}" : "$count ${count == 1 ? "past event" : "past events"}";
  }

  static String groupMembersCount(int count) {
    return isSpanish ? (count == 1 ? "$count miembro" : "$count miembros") : (count == 1 ? "$count member" : "$count members");
  }

  static String get groupNoMembers {
    return isSpanish ? "No tiene miembros" : "No members yet";
  }


  // GROUP CREATE
  // ...
  // ...
  static String get groupCreate {
    return isSpanish ? "Crear" : "Create";
  }

  static String get groupCreateEdit {
    return isSpanish ? "Listo" : "Done";
  }

  static String get groupCreateTitle {
    return isSpanish ? "Crea Nuevo Grupo" : "Create Group";
  }

  static String groupCreateMembersCount(int count) {
    return isSpanish ? (count == 1 ? "$count miembro agregados" : "$count miembros agregados") : (count == 1 ? "$count member added" : "$count members added");
  }

  static String get groupCreateHintDescription {
    return isSpanish ? "Escribe la descripción del grupo" : "Type group's description";
  }

  static String get groupCreateHintName {
    return isSpanish ? "Escribe el nombre del grupo" : "Type group's name";
  }

  static String get groupCreateNoMembers {
    return isSpanish ? "No miembros agregados aún" : "No members added yet";
  }

  static String get groupCreateSearchMembers {
    return isSpanish ? "Busca usuarios para agregar" : "Search users to add";
  }


  // PLACE
  // ...
  // ...
  static String get placeFollowing {
    return isSpanish ? "Siguiendo" : "Following";
  }


  // PLACE SEARCH
  // ...
  // ...

  static String get placeSearchTitle {
    return isSpanish ? "Busca el lugar" : "Search place";
  }


  // USER
  // ...
  // ...
  static String get userActionEdit {
    return isSpanish ? "Editar" : "Edit";
  }

  static String userEventsCreatedActiveCount(int count) {
    return isSpanish ? "$count ${count == 1 ? "evento" : "eventos"}" : "$count ${count == 1 ? "event" : "events"}";
  }

  static String get userActionFollowing {
    return isSpanish ? "Siguiendo" : "Following";
  }

  static String get userActionLogout {
    return isSpanish ? "Logout" : "Logout";
  }

  static String userEventsCreatedInactiveCount(int count) {
    return isSpanish ? "$count ${count == 1 ? "evento" : "eventos"} pasados" : "$count past ${count == 1 ? "event" : "events"}";
  }

  static String userEventsFollowingActiveCount(int count) {
    return isSpanish ? "$count ${count == 1 ? "evento" : "eventos"} siguiendo" : "$count ${count == 1 ? "event" : "events"} following";
  }

  static String userEventsFollowingInactiveCount(int count) {
    return isSpanish ? "$count ${count == 1 ? "evento" : "eventos"} pasados siguiendo" : "$count past ${count == 1 ? "event" : "events"} following";
  }

  static String get userFollowed {
    return isSpanish ? "Siguiendo" : "Following";
  }

  static String get userFollowedBy {
    return isSpanish ? "Seguido por" : "Followed by";
  }

  static String userFollowersCount(int count) {
    return isSpanish ? "$count ${count == 1 ? "seguidor" : "seguidores"}" : "$count ${count == 1 ? "follower" : "followers"}";
  }

  static String userFollowingCount(int count) {
    return isSpanish ? "$count eventos organizados" : "$count organized events";
  }

  static String userMoreFollowersCount(int count) {
    return isSpanish ? "y $count más" : "and $count more";
  }

  static String userMoreFollowingCount(int count) {
    return isSpanish ? "y $count más" : "and $count more";
  }

  static String get userNoFollowing {
    return isSpanish ? "No sigue a nadie todavia" : "Not following anybody yet";
  }

  static String get userNoFollowers {
    return isSpanish ? "No tiene seguidores todavia" : "Not followed yet";
  }

  static String get userReport {
    return isSpanish ? "Reportar" : "Report";
  }


  // USER CREATE
  // ...
  // ...
  static String get userCreate {
    return isSpanish ? "Crear" : "Create";
  }

  static String get userCreateCreate {
    return isSpanish ? "Crea tu perfil para continuar" : "Create your profile to continue";
  }

  static String get userCreateEdit {
    return isSpanish ? "Listo" : "Done";
  }

  static String get userCreateHintDescription {
    return isSpanish ? "Escribe una breve descripcion acerca de ti" : "Enter a short description about yourself";
  }

  static String get userCreateHintName {
    return isSpanish ? "Escribe tu nombre" : "Enter your name";
  }

  static String get userCreateLogin {
    return isSpanish ? "Si ya tienes cuenta continua aqui" : "If you have an account already continue here";
  }

  static String get userCreateHintPassword {
    return isSpanish ? "Escribe tu contraseña" : "Enter your password";
  }

  static String get userCreateTitle {
    return isSpanish ? "Crea usuario" : "Create user";
  }


  // USER CREATE
  // ...
  // ...
  static String get userLogin {
    return isSpanish ? "Login" : "Login";
  }

  static String get userLoginHintName {
    return isSpanish ? "Escribe tu nombre" : "Enter your name";
  }

  static String get userLoginHintPassword {
    return isSpanish ? "Escribe tu contraseña" : "Enter your password";
  }

  static String get userLoginInputIncorrect {
    return isSpanish ? "Incorrecto nombre o contraseña. Intenta de nuevo." : "Incorrect name or password. Please try again.";
  }

  static String get userLoginTitle {
    return isSpanish ? "Login usuario" : "Login user";
  }


  // USER SEARCH
  // ...
  // ...
  static String usersPayloadsTitle(String name, bool areFollowers) {
    return isSpanish ? "${areFollowers ? "seguidores" : "siguiendo"} de $name" : "$name's ${areFollowers ? "followers" : "following"}";
  }


  // USER SEARCH
  // ...
  // ...
  static String get userSearchTitle {
    return isSpanish ? "Agrega usurios" : "Add users";
  }

  static String get userSearch {
    return isSpanish ? "Listo" : "Done";
  }
}
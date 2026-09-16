// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventDateMeta = const VerificationMeta(
    'eventDate',
  );
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
    'event_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandingUrlMeta = const VerificationMeta(
    'brandingUrl',
  );
  @override
  late final GeneratedColumn<String> brandingUrl = GeneratedColumn<String>(
    'branding_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => '',
  );
  static const VerificationMeta _ticketsNumberMeta = const VerificationMeta(
    'ticketsNumber',
  );
  @override
  late final GeneratedColumn<int> ticketsNumber = GeneratedColumn<int>(
    'tickets_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => 0,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EventType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EventType>($EventsTable.$convertertype);
  static const VerificationMeta _brandNameMeta = const VerificationMeta(
    'brandName',
  );
  @override
  late final GeneratedColumn<String> brandName = GeneratedColumn<String>(
    'brand_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventPlaceMeta = const VerificationMeta(
    'eventPlace',
  );
  @override
  late final GeneratedColumn<String> eventPlace = GeneratedColumn<String>(
    'event_place',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxPlacesMeta = const VerificationMeta(
    'maxPlaces',
  );
  @override
  late final GeneratedColumn<int> maxPlaces = GeneratedColumn<int>(
    'max_places',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EventStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EventStatus>($EventsTable.$converterstatus);
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    eventDate,
    startTime,
    brandingUrl,
    ticketsNumber,
    type,
    brandName,
    eventPlace,
    maxPlaces,
    status,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<Event> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('event_date')) {
      context.handle(
        _eventDateMeta,
        eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta),
      );
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('branding_url')) {
      context.handle(
        _brandingUrlMeta,
        brandingUrl.isAcceptableOrUnknown(
          data['branding_url']!,
          _brandingUrlMeta,
        ),
      );
    }
    if (data.containsKey('tickets_number')) {
      context.handle(
        _ticketsNumberMeta,
        ticketsNumber.isAcceptableOrUnknown(
          data['tickets_number']!,
          _ticketsNumberMeta,
        ),
      );
    }
    if (data.containsKey('brand_name')) {
      context.handle(
        _brandNameMeta,
        brandName.isAcceptableOrUnknown(data['brand_name']!, _brandNameMeta),
      );
    } else if (isInserting) {
      context.missing(_brandNameMeta);
    }
    if (data.containsKey('event_place')) {
      context.handle(
        _eventPlaceMeta,
        eventPlace.isAcceptableOrUnknown(data['event_place']!, _eventPlaceMeta),
      );
    } else if (isInserting) {
      context.missing(_eventPlaceMeta);
    }
    if (data.containsKey('max_places')) {
      context.handle(
        _maxPlacesMeta,
        maxPlaces.isAcceptableOrUnknown(data['max_places']!, _maxPlacesMeta),
      );
    } else if (isInserting) {
      context.missing(_maxPlacesMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      eventDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}event_date'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      brandingUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branding_url'],
      )!,
      ticketsNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tickets_number'],
      )!,
      type: $EventsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      brandName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_name'],
      )!,
      eventPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_place'],
      )!,
      maxPlaces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_places'],
      )!,
      status: $EventsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EventType, String, String> $convertertype =
      const EnumNameConverter<EventType>(EventType.values);
  static JsonTypeConverter2<EventStatus, String, String> $converterstatus =
      const EnumNameConverter<EventStatus>(EventStatus.values);
}

class Event extends DataClass implements Insertable<Event> {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final DateTime startTime;
  final String brandingUrl;
  final int ticketsNumber;
  final EventType type;
  final String brandName;
  final String eventPlace;
  final int maxPlaces;
  final EventStatus status;
  final int updatedAtMs;
  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.startTime,
    required this.brandingUrl,
    required this.ticketsNumber,
    required this.type,
    required this.brandName,
    required this.eventPlace,
    required this.maxPlaces,
    required this.status,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['event_date'] = Variable<DateTime>(eventDate);
    map['start_time'] = Variable<DateTime>(startTime);
    map['branding_url'] = Variable<String>(brandingUrl);
    map['tickets_number'] = Variable<int>(ticketsNumber);
    {
      map['type'] = Variable<String>($EventsTable.$convertertype.toSql(type));
    }
    map['brand_name'] = Variable<String>(brandName);
    map['event_place'] = Variable<String>(eventPlace);
    map['max_places'] = Variable<int>(maxPlaces);
    {
      map['status'] = Variable<String>(
        $EventsTable.$converterstatus.toSql(status),
      );
    }
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      eventDate: Value(eventDate),
      startTime: Value(startTime),
      brandingUrl: Value(brandingUrl),
      ticketsNumber: Value(ticketsNumber),
      type: Value(type),
      brandName: Value(brandName),
      eventPlace: Value(eventPlace),
      maxPlaces: Value(maxPlaces),
      status: Value(status),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory Event.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      eventDate: serializer.fromJson<DateTime>(json['eventDate']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      brandingUrl: serializer.fromJson<String>(json['brandingUrl']),
      ticketsNumber: serializer.fromJson<int>(json['ticketsNumber']),
      type: $EventsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      brandName: serializer.fromJson<String>(json['brandName']),
      eventPlace: serializer.fromJson<String>(json['eventPlace']),
      maxPlaces: serializer.fromJson<int>(json['maxPlaces']),
      status: $EventsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'eventDate': serializer.toJson<DateTime>(eventDate),
      'startTime': serializer.toJson<DateTime>(startTime),
      'brandingUrl': serializer.toJson<String>(brandingUrl),
      'ticketsNumber': serializer.toJson<int>(ticketsNumber),
      'type': serializer.toJson<String>(
        $EventsTable.$convertertype.toJson(type),
      ),
      'brandName': serializer.toJson<String>(brandName),
      'eventPlace': serializer.toJson<String>(eventPlace),
      'maxPlaces': serializer.toJson<int>(maxPlaces),
      'status': serializer.toJson<String>(
        $EventsTable.$converterstatus.toJson(status),
      ),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? eventDate,
    DateTime? startTime,
    String? brandingUrl,
    int? ticketsNumber,
    EventType? type,
    String? brandName,
    String? eventPlace,
    int? maxPlaces,
    EventStatus? status,
    int? updatedAtMs,
  }) => Event(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    eventDate: eventDate ?? this.eventDate,
    startTime: startTime ?? this.startTime,
    brandingUrl: brandingUrl ?? this.brandingUrl,
    ticketsNumber: ticketsNumber ?? this.ticketsNumber,
    type: type ?? this.type,
    brandName: brandName ?? this.brandName,
    eventPlace: eventPlace ?? this.eventPlace,
    maxPlaces: maxPlaces ?? this.maxPlaces,
    status: status ?? this.status,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      brandingUrl: data.brandingUrl.present
          ? data.brandingUrl.value
          : this.brandingUrl,
      ticketsNumber: data.ticketsNumber.present
          ? data.ticketsNumber.value
          : this.ticketsNumber,
      type: data.type.present ? data.type.value : this.type,
      brandName: data.brandName.present ? data.brandName.value : this.brandName,
      eventPlace: data.eventPlace.present
          ? data.eventPlace.value
          : this.eventPlace,
      maxPlaces: data.maxPlaces.present ? data.maxPlaces.value : this.maxPlaces,
      status: data.status.present ? data.status.value : this.status,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('eventDate: $eventDate, ')
          ..write('startTime: $startTime, ')
          ..write('brandingUrl: $brandingUrl, ')
          ..write('ticketsNumber: $ticketsNumber, ')
          ..write('type: $type, ')
          ..write('brandName: $brandName, ')
          ..write('eventPlace: $eventPlace, ')
          ..write('maxPlaces: $maxPlaces, ')
          ..write('status: $status, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    eventDate,
    startTime,
    brandingUrl,
    ticketsNumber,
    type,
    brandName,
    eventPlace,
    maxPlaces,
    status,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.eventDate == this.eventDate &&
          other.startTime == this.startTime &&
          other.brandingUrl == this.brandingUrl &&
          other.ticketsNumber == this.ticketsNumber &&
          other.type == this.type &&
          other.brandName == this.brandName &&
          other.eventPlace == this.eventPlace &&
          other.maxPlaces == this.maxPlaces &&
          other.status == this.status &&
          other.updatedAtMs == this.updatedAtMs);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime> eventDate;
  final Value<DateTime> startTime;
  final Value<String> brandingUrl;
  final Value<int> ticketsNumber;
  final Value<EventType> type;
  final Value<String> brandName;
  final Value<String> eventPlace;
  final Value<int> maxPlaces;
  final Value<EventStatus> status;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.startTime = const Value.absent(),
    this.brandingUrl = const Value.absent(),
    this.ticketsNumber = const Value.absent(),
    this.type = const Value.absent(),
    this.brandName = const Value.absent(),
    this.eventPlace = const Value.absent(),
    this.maxPlaces = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String title,
    required String description,
    required DateTime eventDate,
    required DateTime startTime,
    this.brandingUrl = const Value.absent(),
    this.ticketsNumber = const Value.absent(),
    required EventType type,
    required String brandName,
    required String eventPlace,
    required int maxPlaces,
    required EventStatus status,
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       description = Value(description),
       eventDate = Value(eventDate),
       startTime = Value(startTime),
       type = Value(type),
       brandName = Value(brandName),
       eventPlace = Value(eventPlace),
       maxPlaces = Value(maxPlaces),
       status = Value(status);
  static Insertable<Event> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? eventDate,
    Expression<DateTime>? startTime,
    Expression<String>? brandingUrl,
    Expression<int>? ticketsNumber,
    Expression<String>? type,
    Expression<String>? brandName,
    Expression<String>? eventPlace,
    Expression<int>? maxPlaces,
    Expression<String>? status,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (eventDate != null) 'event_date': eventDate,
      if (startTime != null) 'start_time': startTime,
      if (brandingUrl != null) 'branding_url': brandingUrl,
      if (ticketsNumber != null) 'tickets_number': ticketsNumber,
      if (type != null) 'type': type,
      if (brandName != null) 'brand_name': brandName,
      if (eventPlace != null) 'event_place': eventPlace,
      if (maxPlaces != null) 'max_places': maxPlaces,
      if (status != null) 'status': status,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<DateTime>? eventDate,
    Value<DateTime>? startTime,
    Value<String>? brandingUrl,
    Value<int>? ticketsNumber,
    Value<EventType>? type,
    Value<String>? brandName,
    Value<String>? eventPlace,
    Value<int>? maxPlaces,
    Value<EventStatus>? status,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime ?? this.startTime,
      brandingUrl: brandingUrl ?? this.brandingUrl,
      ticketsNumber: ticketsNumber ?? this.ticketsNumber,
      type: type ?? this.type,
      brandName: brandName ?? this.brandName,
      eventPlace: eventPlace ?? this.eventPlace,
      maxPlaces: maxPlaces ?? this.maxPlaces,
      status: status ?? this.status,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (brandingUrl.present) {
      map['branding_url'] = Variable<String>(brandingUrl.value);
    }
    if (ticketsNumber.present) {
      map['tickets_number'] = Variable<int>(ticketsNumber.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $EventsTable.$convertertype.toSql(type.value),
      );
    }
    if (brandName.present) {
      map['brand_name'] = Variable<String>(brandName.value);
    }
    if (eventPlace.present) {
      map['event_place'] = Variable<String>(eventPlace.value);
    }
    if (maxPlaces.present) {
      map['max_places'] = Variable<int>(maxPlaces.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $EventsTable.$converterstatus.toSql(status.value),
      );
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('eventDate: $eventDate, ')
          ..write('startTime: $startTime, ')
          ..write('brandingUrl: $brandingUrl, ')
          ..write('ticketsNumber: $ticketsNumber, ')
          ..write('type: $type, ')
          ..write('brandName: $brandName, ')
          ..write('eventPlace: $eventPlace, ')
          ..write('maxPlaces: $maxPlaces, ')
          ..write('status: $status, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TicketsTable extends Tickets with TableInfo<$TicketsTable, Ticket> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TicketsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TicketStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TicketStatus>($TicketsTable.$converterstatus);
  static const VerificationMeta _uniqueCodeMeta = const VerificationMeta(
    'uniqueCode',
  );
  @override
  late final GeneratedColumn<String> uniqueCode = GeneratedColumn<String>(
    'unique_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _qrSignatureMeta = const VerificationMeta(
    'qrSignature',
  );
  @override
  late final GeneratedColumn<String> qrSignature = GeneratedColumn<String>(
    'qr_signature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id)',
    ),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    status,
    uniqueCode,
    qrSignature,
    userId,
    eventId,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tickets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ticket> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('unique_code')) {
      context.handle(
        _uniqueCodeMeta,
        uniqueCode.isAcceptableOrUnknown(data['unique_code']!, _uniqueCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_uniqueCodeMeta);
    }
    if (data.containsKey('qr_signature')) {
      context.handle(
        _qrSignatureMeta,
        qrSignature.isAcceptableOrUnknown(
          data['qr_signature']!,
          _qrSignatureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_qrSignatureMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ticket map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ticket(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      status: $TicketsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      uniqueCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unique_code'],
      )!,
      qrSignature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qr_signature'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $TicketsTable createAlias(String alias) {
    return $TicketsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TicketStatus, String, String> $converterstatus =
      const EnumNameConverter<TicketStatus>(TicketStatus.values);
}

class Ticket extends DataClass implements Insertable<Ticket> {
  final String id;
  final TicketStatus status;
  final String uniqueCode;
  final String qrSignature;
  final String userId;
  final String eventId;
  final int updatedAtMs;
  const Ticket({
    required this.id,
    required this.status,
    required this.uniqueCode,
    required this.qrSignature,
    required this.userId,
    required this.eventId,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['status'] = Variable<String>(
        $TicketsTable.$converterstatus.toSql(status),
      );
    }
    map['unique_code'] = Variable<String>(uniqueCode);
    map['qr_signature'] = Variable<String>(qrSignature);
    map['user_id'] = Variable<String>(userId);
    map['event_id'] = Variable<String>(eventId);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  TicketsCompanion toCompanion(bool nullToAbsent) {
    return TicketsCompanion(
      id: Value(id),
      status: Value(status),
      uniqueCode: Value(uniqueCode),
      qrSignature: Value(qrSignature),
      userId: Value(userId),
      eventId: Value(eventId),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory Ticket.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ticket(
      id: serializer.fromJson<String>(json['id']),
      status: $TicketsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      uniqueCode: serializer.fromJson<String>(json['uniqueCode']),
      qrSignature: serializer.fromJson<String>(json['qrSignature']),
      userId: serializer.fromJson<String>(json['userId']),
      eventId: serializer.fromJson<String>(json['eventId']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'status': serializer.toJson<String>(
        $TicketsTable.$converterstatus.toJson(status),
      ),
      'uniqueCode': serializer.toJson<String>(uniqueCode),
      'qrSignature': serializer.toJson<String>(qrSignature),
      'userId': serializer.toJson<String>(userId),
      'eventId': serializer.toJson<String>(eventId),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  Ticket copyWith({
    String? id,
    TicketStatus? status,
    String? uniqueCode,
    String? qrSignature,
    String? userId,
    String? eventId,
    int? updatedAtMs,
  }) => Ticket(
    id: id ?? this.id,
    status: status ?? this.status,
    uniqueCode: uniqueCode ?? this.uniqueCode,
    qrSignature: qrSignature ?? this.qrSignature,
    userId: userId ?? this.userId,
    eventId: eventId ?? this.eventId,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  Ticket copyWithCompanion(TicketsCompanion data) {
    return Ticket(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      uniqueCode: data.uniqueCode.present
          ? data.uniqueCode.value
          : this.uniqueCode,
      qrSignature: data.qrSignature.present
          ? data.qrSignature.value
          : this.qrSignature,
      userId: data.userId.present ? data.userId.value : this.userId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ticket(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('uniqueCode: $uniqueCode, ')
          ..write('qrSignature: $qrSignature, ')
          ..write('userId: $userId, ')
          ..write('eventId: $eventId, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    status,
    uniqueCode,
    qrSignature,
    userId,
    eventId,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ticket &&
          other.id == this.id &&
          other.status == this.status &&
          other.uniqueCode == this.uniqueCode &&
          other.qrSignature == this.qrSignature &&
          other.userId == this.userId &&
          other.eventId == this.eventId &&
          other.updatedAtMs == this.updatedAtMs);
}

class TicketsCompanion extends UpdateCompanion<Ticket> {
  final Value<String> id;
  final Value<TicketStatus> status;
  final Value<String> uniqueCode;
  final Value<String> qrSignature;
  final Value<String> userId;
  final Value<String> eventId;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const TicketsCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.uniqueCode = const Value.absent(),
    this.qrSignature = const Value.absent(),
    this.userId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TicketsCompanion.insert({
    required String id,
    required TicketStatus status,
    required String uniqueCode,
    required String qrSignature,
    required String userId,
    required String eventId,
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       status = Value(status),
       uniqueCode = Value(uniqueCode),
       qrSignature = Value(qrSignature),
       userId = Value(userId),
       eventId = Value(eventId);
  static Insertable<Ticket> custom({
    Expression<String>? id,
    Expression<String>? status,
    Expression<String>? uniqueCode,
    Expression<String>? qrSignature,
    Expression<String>? userId,
    Expression<String>? eventId,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (uniqueCode != null) 'unique_code': uniqueCode,
      if (qrSignature != null) 'qr_signature': qrSignature,
      if (userId != null) 'user_id': userId,
      if (eventId != null) 'event_id': eventId,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TicketsCompanion copyWith({
    Value<String>? id,
    Value<TicketStatus>? status,
    Value<String>? uniqueCode,
    Value<String>? qrSignature,
    Value<String>? userId,
    Value<String>? eventId,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return TicketsCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      uniqueCode: uniqueCode ?? this.uniqueCode,
      qrSignature: qrSignature ?? this.qrSignature,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TicketsTable.$converterstatus.toSql(status.value),
      );
    }
    if (uniqueCode.present) {
      map['unique_code'] = Variable<String>(uniqueCode.value);
    }
    if (qrSignature.present) {
      map['qr_signature'] = Variable<String>(qrSignature.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TicketsCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('uniqueCode: $uniqueCode, ')
          ..write('qrSignature: $qrSignature, ')
          ..write('userId: $userId, ')
          ..write('eventId: $eventId, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventUserRolesTable extends EventUserRoles
    with TableInfo<$EventUserRolesTable, EventUserRole> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventUserRolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Role, String> role =
      GeneratedColumn<String>(
        'role',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Role>($EventUserRolesTable.$converterrole);
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [userId, eventId, role, updatedAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_user_roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventUserRole> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, eventId, role};
  @override
  EventUserRole map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventUserRole(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      role: $EventUserRolesTable.$converterrole.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}role'],
        )!,
      ),
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $EventUserRolesTable createAlias(String alias) {
    return $EventUserRolesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Role, String, String> $converterrole =
      const EnumNameConverter<Role>(Role.values);
}

class EventUserRole extends DataClass implements Insertable<EventUserRole> {
  final String userId;
  final String eventId;
  final Role role;
  final int updatedAtMs;
  const EventUserRole({
    required this.userId,
    required this.eventId,
    required this.role,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['event_id'] = Variable<String>(eventId);
    {
      map['role'] = Variable<String>(
        $EventUserRolesTable.$converterrole.toSql(role),
      );
    }
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  EventUserRolesCompanion toCompanion(bool nullToAbsent) {
    return EventUserRolesCompanion(
      userId: Value(userId),
      eventId: Value(eventId),
      role: Value(role),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory EventUserRole.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventUserRole(
      userId: serializer.fromJson<String>(json['userId']),
      eventId: serializer.fromJson<String>(json['eventId']),
      role: $EventUserRolesTable.$converterrole.fromJson(
        serializer.fromJson<String>(json['role']),
      ),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'eventId': serializer.toJson<String>(eventId),
      'role': serializer.toJson<String>(
        $EventUserRolesTable.$converterrole.toJson(role),
      ),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  EventUserRole copyWith({
    String? userId,
    String? eventId,
    Role? role,
    int? updatedAtMs,
  }) => EventUserRole(
    userId: userId ?? this.userId,
    eventId: eventId ?? this.eventId,
    role: role ?? this.role,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  EventUserRole copyWithCompanion(EventUserRolesCompanion data) {
    return EventUserRole(
      userId: data.userId.present ? data.userId.value : this.userId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      role: data.role.present ? data.role.value : this.role,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventUserRole(')
          ..write('userId: $userId, ')
          ..write('eventId: $eventId, ')
          ..write('role: $role, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, eventId, role, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventUserRole &&
          other.userId == this.userId &&
          other.eventId == this.eventId &&
          other.role == this.role &&
          other.updatedAtMs == this.updatedAtMs);
}

class EventUserRolesCompanion extends UpdateCompanion<EventUserRole> {
  final Value<String> userId;
  final Value<String> eventId;
  final Value<Role> role;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const EventUserRolesCompanion({
    this.userId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.role = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventUserRolesCompanion.insert({
    required String userId,
    required String eventId,
    required Role role,
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       eventId = Value(eventId),
       role = Value(role);
  static Insertable<EventUserRole> custom({
    Expression<String>? userId,
    Expression<String>? eventId,
    Expression<String>? role,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (eventId != null) 'event_id': eventId,
      if (role != null) 'role': role,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventUserRolesCompanion copyWith({
    Value<String>? userId,
    Value<String>? eventId,
    Value<Role>? role,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return EventUserRolesCompanion(
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      role: role ?? this.role,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(
        $EventUserRolesTable.$converterrole.toSql(role.value),
      );
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventUserRolesCompanion(')
          ..write('userId: $userId, ')
          ..write('eventId: $eventId, ')
          ..write('role: $role, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preconditionMeta = const VerificationMeta(
    'precondition',
  );
  @override
  late final GeneratedColumn<String> precondition = GeneratedColumn<String>(
    'precondition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextRetryAtMsMeta = const VerificationMeta(
    'nextRetryAtMs',
  );
  @override
  late final GeneratedColumn<int> nextRetryAtMs = GeneratedColumn<int>(
    'next_retry_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    op,
    precondition,
    payload,
    status,
    createdAtMs,
    attempts,
    nextRetryAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('precondition')) {
      context.handle(
        _preconditionMeta,
        precondition.isAcceptableOrUnknown(
          data['precondition']!,
          _preconditionMeta,
        ),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_retry_at_ms')) {
      context.handle(
        _nextRetryAtMsMeta,
        nextRetryAtMs.isAcceptableOrUnknown(
          data['next_retry_at_ms']!,
          _nextRetryAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      precondition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}precondition'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextRetryAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_retry_at_ms'],
      ),
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final String id;
  final String entityType;
  final String entityId;
  final String op;
  final String? precondition;
  final String payload;
  final String status;
  final int createdAtMs;
  final int attempts;
  final int? nextRetryAtMs;
  const SyncOutboxData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.op,
    this.precondition,
    required this.payload,
    required this.status,
    required this.createdAtMs,
    required this.attempts,
    this.nextRetryAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['op'] = Variable<String>(op);
    if (!nullToAbsent || precondition != null) {
      map['precondition'] = Variable<String>(precondition);
    }
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextRetryAtMs != null) {
      map['next_retry_at_ms'] = Variable<int>(nextRetryAtMs);
    }
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      op: Value(op),
      precondition: precondition == null && nullToAbsent
          ? const Value.absent()
          : Value(precondition),
      payload: Value(payload),
      status: Value(status),
      createdAtMs: Value(createdAtMs),
      attempts: Value(attempts),
      nextRetryAtMs: nextRetryAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAtMs),
    );
  }

  factory SyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      op: serializer.fromJson<String>(json['op']),
      precondition: serializer.fromJson<String?>(json['precondition']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextRetryAtMs: serializer.fromJson<int?>(json['nextRetryAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'op': serializer.toJson<String>(op),
      'precondition': serializer.toJson<String?>(precondition),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'attempts': serializer.toJson<int>(attempts),
      'nextRetryAtMs': serializer.toJson<int?>(nextRetryAtMs),
    };
  }

  SyncOutboxData copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? op,
    Value<String?> precondition = const Value.absent(),
    String? payload,
    String? status,
    int? createdAtMs,
    int? attempts,
    Value<int?> nextRetryAtMs = const Value.absent(),
  }) => SyncOutboxData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    op: op ?? this.op,
    precondition: precondition.present ? precondition.value : this.precondition,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    attempts: attempts ?? this.attempts,
    nextRetryAtMs: nextRetryAtMs.present
        ? nextRetryAtMs.value
        : this.nextRetryAtMs,
  );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      op: data.op.present ? data.op.value : this.op,
      precondition: data.precondition.present
          ? data.precondition.value
          : this.precondition,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextRetryAtMs: data.nextRetryAtMs.present
          ? data.nextRetryAtMs.value
          : this.nextRetryAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('precondition: $precondition, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('attempts: $attempts, ')
          ..write('nextRetryAtMs: $nextRetryAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    op,
    precondition,
    payload,
    status,
    createdAtMs,
    attempts,
    nextRetryAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.op == this.op &&
          other.precondition == this.precondition &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.createdAtMs == this.createdAtMs &&
          other.attempts == this.attempts &&
          other.nextRetryAtMs == this.nextRetryAtMs);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> op;
  final Value<String?> precondition;
  final Value<String> payload;
  final Value<String> status;
  final Value<int> createdAtMs;
  final Value<int> attempts;
  final Value<int?> nextRetryAtMs;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.op = const Value.absent(),
    this.precondition = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextRetryAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String op,
    this.precondition = const Value.absent(),
    required String payload,
    required String status,
    required int createdAtMs,
    this.attempts = const Value.absent(),
    this.nextRetryAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       op = Value(op),
       payload = Value(payload),
       status = Value(status),
       createdAtMs = Value(createdAtMs);
  static Insertable<SyncOutboxData> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? op,
    Expression<String>? precondition,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? createdAtMs,
    Expression<int>? attempts,
    Expression<int>? nextRetryAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (op != null) 'op': op,
      if (precondition != null) 'precondition': precondition,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (attempts != null) 'attempts': attempts,
      if (nextRetryAtMs != null) 'next_retry_at_ms': nextRetryAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? op,
    Value<String?>? precondition,
    Value<String>? payload,
    Value<String>? status,
    Value<int>? createdAtMs,
    Value<int>? attempts,
    Value<int?>? nextRetryAtMs,
    Value<int>? rowid,
  }) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      op: op ?? this.op,
      precondition: precondition ?? this.precondition,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      attempts: attempts ?? this.attempts,
      nextRetryAtMs: nextRetryAtMs ?? this.nextRetryAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (precondition.present) {
      map['precondition'] = Variable<String>(precondition.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextRetryAtMs.present) {
      map['next_retry_at_ms'] = Variable<int>(nextRetryAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('precondition: $precondition, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('attempts: $attempts, ')
          ..write('nextRetryAtMs: $nextRetryAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EventsTable events = $EventsTable(this);
  late final $TicketsTable tickets = $TicketsTable(this);
  late final $EventUserRolesTable eventUserRoles = $EventUserRolesTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    events,
    tickets,
    eventUserRoles,
    syncOutbox,
  ];
}

typedef $$EventsTableCreateCompanionBuilder =
    EventsCompanion Function({
      required String id,
      required String title,
      required String description,
      required DateTime eventDate,
      required DateTime startTime,
      Value<String> brandingUrl,
      Value<int> ticketsNumber,
      required EventType type,
      required String brandName,
      required String eventPlace,
      required int maxPlaces,
      required EventStatus status,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });
typedef $$EventsTableUpdateCompanionBuilder =
    EventsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<DateTime> eventDate,
      Value<DateTime> startTime,
      Value<String> brandingUrl,
      Value<int> ticketsNumber,
      Value<EventType> type,
      Value<String> brandName,
      Value<String> eventPlace,
      Value<int> maxPlaces,
      Value<EventStatus> status,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

final class $$EventsTableReferences
    extends BaseReferences<_$AppDatabase, $EventsTable, Event> {
  $$EventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TicketsTable, List<Ticket>> _ticketsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tickets,
    aliasName: 'events__id__tickets__event_id',
  );

  $$TicketsTableProcessedTableManager get ticketsRefs {
    final manager = $$TicketsTableTableManager(
      $_db,
      $_db.tickets,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ticketsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventUserRolesTable, List<EventUserRole>>
  _eventUserRolesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eventUserRoles,
    aliasName: 'events__id__event_user_roles__event_id',
  );

  $$EventUserRolesTableProcessedTableManager get eventUserRolesRefs {
    final manager = $$EventUserRolesTableTableManager(
      $_db,
      $_db.eventUserRoles,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventUserRolesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brandingUrl => $composableBuilder(
    column: $table.brandingUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ticketsNumber => $composableBuilder(
    column: $table.ticketsNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EventType, EventType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventPlace => $composableBuilder(
    column: $table.eventPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxPlaces => $composableBuilder(
    column: $table.maxPlaces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EventStatus, EventStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ticketsRefs(
    Expression<bool> Function($$TicketsTableFilterComposer f) f,
  ) {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableFilterComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventUserRolesRefs(
    Expression<bool> Function($$EventUserRolesTableFilterComposer f) f,
  ) {
    final $$EventUserRolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventUserRoles,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventUserRolesTableFilterComposer(
            $db: $db,
            $table: $db.eventUserRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandingUrl => $composableBuilder(
    column: $table.brandingUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ticketsNumber => $composableBuilder(
    column: $table.ticketsNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventPlace => $composableBuilder(
    column: $table.eventPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxPlaces => $composableBuilder(
    column: $table.maxPlaces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get brandingUrl => $composableBuilder(
    column: $table.brandingUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ticketsNumber => $composableBuilder(
    column: $table.ticketsNumber,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<EventType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get brandName =>
      $composableBuilder(column: $table.brandName, builder: (column) => column);

  GeneratedColumn<String> get eventPlace => $composableBuilder(
    column: $table.eventPlace,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxPlaces =>
      $composableBuilder(column: $table.maxPlaces, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EventStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  Expression<T> ticketsRefs<T extends Object>(
    Expression<T> Function($$TicketsTableAnnotationComposer a) f,
  ) {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableAnnotationComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventUserRolesRefs<T extends Object>(
    Expression<T> Function($$EventUserRolesTableAnnotationComposer a) f,
  ) {
    final $$EventUserRolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventUserRoles,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventUserRolesTableAnnotationComposer(
            $db: $db,
            $table: $db.eventUserRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          Event,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (Event, $$EventsTableReferences),
          Event,
          PrefetchHooks Function({bool ticketsRefs, bool eventUserRolesRefs})
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> eventDate = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<String> brandingUrl = const Value.absent(),
                Value<int> ticketsNumber = const Value.absent(),
                Value<EventType> type = const Value.absent(),
                Value<String> brandName = const Value.absent(),
                Value<String> eventPlace = const Value.absent(),
                Value<int> maxPlaces = const Value.absent(),
                Value<EventStatus> status = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                title: title,
                description: description,
                eventDate: eventDate,
                startTime: startTime,
                brandingUrl: brandingUrl,
                ticketsNumber: ticketsNumber,
                type: type,
                brandName: brandName,
                eventPlace: eventPlace,
                maxPlaces: maxPlaces,
                status: status,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String description,
                required DateTime eventDate,
                required DateTime startTime,
                Value<String> brandingUrl = const Value.absent(),
                Value<int> ticketsNumber = const Value.absent(),
                required EventType type,
                required String brandName,
                required String eventPlace,
                required int maxPlaces,
                required EventStatus status,
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                title: title,
                description: description,
                eventDate: eventDate,
                startTime: startTime,
                brandingUrl: brandingUrl,
                ticketsNumber: ticketsNumber,
                type: type,
                brandName: brandName,
                eventPlace: eventPlace,
                maxPlaces: maxPlaces,
                status: status,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventsTable, Event>(table),
                  $$EventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({ticketsRefs = false, eventUserRolesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ticketsRefs) db.tickets,
                    if (eventUserRolesRefs) db.eventUserRoles,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ticketsRefs)
                        await $_getPrefetchedData<Event, $EventsTable, Ticket>(
                          currentTable: table,
                          referencedTable: $$EventsTableReferences
                              ._ticketsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventsTableReferences(
                                db,
                                table,
                                p0,
                              ).ticketsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventUserRolesRefs)
                        await $_getPrefetchedData<
                          Event,
                          $EventsTable,
                          EventUserRole
                        >(
                          currentTable: table,
                          referencedTable: $$EventsTableReferences
                              ._eventUserRolesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventsTableReferences(
                                db,
                                table,
                                p0,
                              ).eventUserRolesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      Event,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (Event, $$EventsTableReferences),
      Event,
      PrefetchHooks Function({bool ticketsRefs, bool eventUserRolesRefs})
    >;
typedef $$TicketsTableCreateCompanionBuilder =
    TicketsCompanion Function({
      required String id,
      required TicketStatus status,
      required String uniqueCode,
      required String qrSignature,
      required String userId,
      required String eventId,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });
typedef $$TicketsTableUpdateCompanionBuilder =
    TicketsCompanion Function({
      Value<String> id,
      Value<TicketStatus> status,
      Value<String> uniqueCode,
      Value<String> qrSignature,
      Value<String> userId,
      Value<String> eventId,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

final class $$TicketsTableReferences
    extends BaseReferences<_$AppDatabase, $TicketsTable, Ticket> {
  $$TicketsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EventsTable _eventIdTable(_$AppDatabase db) =>
      db.events.createAlias('tickets__event_id__events__id');

  $$EventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<String>('event_id')!;

    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TicketsTableFilterComposer
    extends Composer<_$AppDatabase, $TicketsTable> {
  $$TicketsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TicketStatus, TicketStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get uniqueCode => $composableBuilder(
    column: $table.uniqueCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qrSignature => $composableBuilder(
    column: $table.qrSignature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TicketsTableOrderingComposer
    extends Composer<_$AppDatabase, $TicketsTable> {
  $$TicketsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uniqueCode => $composableBuilder(
    column: $table.uniqueCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qrSignature => $composableBuilder(
    column: $table.qrSignature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TicketsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TicketsTable> {
  $$TicketsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TicketStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get uniqueCode => $composableBuilder(
    column: $table.uniqueCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qrSignature => $composableBuilder(
    column: $table.qrSignature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TicketsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TicketsTable,
          Ticket,
          $$TicketsTableFilterComposer,
          $$TicketsTableOrderingComposer,
          $$TicketsTableAnnotationComposer,
          $$TicketsTableCreateCompanionBuilder,
          $$TicketsTableUpdateCompanionBuilder,
          (Ticket, $$TicketsTableReferences),
          Ticket,
          PrefetchHooks Function({bool eventId})
        > {
  $$TicketsTableTableManager(_$AppDatabase db, $TicketsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TicketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TicketsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TicketsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<TicketStatus> status = const Value.absent(),
                Value<String> uniqueCode = const Value.absent(),
                Value<String> qrSignature = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TicketsCompanion(
                id: id,
                status: status,
                uniqueCode: uniqueCode,
                qrSignature: qrSignature,
                userId: userId,
                eventId: eventId,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required TicketStatus status,
                required String uniqueCode,
                required String qrSignature,
                required String userId,
                required String eventId,
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TicketsCompanion.insert(
                id: id,
                status: status,
                uniqueCode: uniqueCode,
                qrSignature: qrSignature,
                userId: userId,
                eventId: eventId,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TicketsTable, Ticket>(table),
                  $$TicketsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (eventId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.eventId,
                                referencedTable: $$TicketsTableReferences
                                    ._eventIdTable(db),
                                referencedColumn: $$TicketsTableReferences
                                    ._eventIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TicketsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TicketsTable,
      Ticket,
      $$TicketsTableFilterComposer,
      $$TicketsTableOrderingComposer,
      $$TicketsTableAnnotationComposer,
      $$TicketsTableCreateCompanionBuilder,
      $$TicketsTableUpdateCompanionBuilder,
      (Ticket, $$TicketsTableReferences),
      Ticket,
      PrefetchHooks Function({bool eventId})
    >;
typedef $$EventUserRolesTableCreateCompanionBuilder =
    EventUserRolesCompanion Function({
      required String userId,
      required String eventId,
      required Role role,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });
typedef $$EventUserRolesTableUpdateCompanionBuilder =
    EventUserRolesCompanion Function({
      Value<String> userId,
      Value<String> eventId,
      Value<Role> role,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

final class $$EventUserRolesTableReferences
    extends BaseReferences<_$AppDatabase, $EventUserRolesTable, EventUserRole> {
  $$EventUserRolesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EventsTable _eventIdTable(_$AppDatabase db) =>
      db.events.createAlias('event_user_roles__event_id__events__id');

  $$EventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<String>('event_id')!;

    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventUserRolesTableFilterComposer
    extends Composer<_$AppDatabase, $EventUserRolesTable> {
  $$EventUserRolesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Role, Role, String> get role =>
      $composableBuilder(
        column: $table.role,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventUserRolesTableOrderingComposer
    extends Composer<_$AppDatabase, $EventUserRolesTable> {
  $$EventUserRolesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventUserRolesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventUserRolesTable> {
  $$EventUserRolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Role, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventUserRolesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventUserRolesTable,
          EventUserRole,
          $$EventUserRolesTableFilterComposer,
          $$EventUserRolesTableOrderingComposer,
          $$EventUserRolesTableAnnotationComposer,
          $$EventUserRolesTableCreateCompanionBuilder,
          $$EventUserRolesTableUpdateCompanionBuilder,
          (EventUserRole, $$EventUserRolesTableReferences),
          EventUserRole,
          PrefetchHooks Function({bool eventId})
        > {
  $$EventUserRolesTableTableManager(
    _$AppDatabase db,
    $EventUserRolesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventUserRolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventUserRolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventUserRolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<Role> role = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventUserRolesCompanion(
                userId: userId,
                eventId: eventId,
                role: role,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String eventId,
                required Role role,
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventUserRolesCompanion.insert(
                userId: userId,
                eventId: eventId,
                role: role,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventUserRolesTable, EventUserRole>(table),
                  $$EventUserRolesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (eventId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.eventId,
                                referencedTable: $$EventUserRolesTableReferences
                                    ._eventIdTable(db),
                                referencedColumn:
                                    $$EventUserRolesTableReferences
                                        ._eventIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EventUserRolesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventUserRolesTable,
      EventUserRole,
      $$EventUserRolesTableFilterComposer,
      $$EventUserRolesTableOrderingComposer,
      $$EventUserRolesTableAnnotationComposer,
      $$EventUserRolesTableCreateCompanionBuilder,
      $$EventUserRolesTableUpdateCompanionBuilder,
      (EventUserRole, $$EventUserRolesTableReferences),
      EventUserRole,
      PrefetchHooks Function({bool eventId})
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required String op,
      Value<String?> precondition,
      required String payload,
      required String status,
      required int createdAtMs,
      Value<int> attempts,
      Value<int?> nextRetryAtMs,
      Value<int> rowid,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> op,
      Value<String?> precondition,
      Value<String> payload,
      Value<String> status,
      Value<int> createdAtMs,
      Value<int> attempts,
      Value<int?> nextRetryAtMs,
      Value<int> rowid,
    });

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get precondition => $composableBuilder(
    column: $table.precondition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextRetryAtMs => $composableBuilder(
    column: $table.nextRetryAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get precondition => $composableBuilder(
    column: $table.precondition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextRetryAtMs => $composableBuilder(
    column: $table.nextRetryAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get precondition => $composableBuilder(
    column: $table.precondition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get nextRetryAtMs => $composableBuilder(
    column: $table.nextRetryAtMs,
    builder: (column) => column,
  );
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          SyncOutboxData,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxData,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
          ),
          SyncOutboxData,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String?> precondition = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int?> nextRetryAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                op: op,
                precondition: precondition,
                payload: payload,
                status: status,
                createdAtMs: createdAtMs,
                attempts: attempts,
                nextRetryAtMs: nextRetryAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required String op,
                Value<String?> precondition = const Value.absent(),
                required String payload,
                required String status,
                required int createdAtMs,
                Value<int> attempts = const Value.absent(),
                Value<int?> nextRetryAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                op: op,
                precondition: precondition,
                payload: payload,
                status: status,
                createdAtMs: createdAtMs,
                attempts: attempts,
                nextRetryAtMs: nextRetryAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncOutboxTable, SyncOutboxData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncOutboxTable,
                    SyncOutboxData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      SyncOutboxData,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxData,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
      ),
      SyncOutboxData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$TicketsTableTableManager get tickets =>
      $$TicketsTableTableManager(_db, _db.tickets);
  $$EventUserRolesTableTableManager get eventUserRoles =>
      $$EventUserRolesTableTableManager(_db, _db.eventUserRoles);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
}

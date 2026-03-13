// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CampaignRecordsTable extends CampaignRecords
    with TableInfo<$CampaignRecordsTable, CampaignRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CampaignRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _startsAtMeta = const VerificationMeta(
    'startsAt',
  );
  @override
  late final GeneratedColumn<DateTime> startsAt = GeneratedColumn<DateTime>(
    'starts_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsAtMeta = const VerificationMeta('endsAt');
  @override
  late final GeneratedColumn<DateTime> endsAt = GeneratedColumn<DateTime>(
    'ends_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    startsAt,
    endsAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'campaign_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CampaignRecord> instance, {
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
    if (data.containsKey('starts_at')) {
      context.handle(
        _startsAtMeta,
        startsAt.isAcceptableOrUnknown(data['starts_at']!, _startsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startsAtMeta);
    }
    if (data.containsKey('ends_at')) {
      context.handle(
        _endsAtMeta,
        endsAt.isAcceptableOrUnknown(data['ends_at']!, _endsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endsAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CampaignRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CampaignRecord(
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
      startsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_at'],
      )!,
      endsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ends_at'],
      )!,
    );
  }

  @override
  $CampaignRecordsTable createAlias(String alias) {
    return $CampaignRecordsTable(attachedDatabase, alias);
  }
}

class CampaignRecord extends DataClass implements Insertable<CampaignRecord> {
  final String id;
  final String title;
  final String description;
  final DateTime startsAt;
  final DateTime endsAt;
  const CampaignRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.endsAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['starts_at'] = Variable<DateTime>(startsAt);
    map['ends_at'] = Variable<DateTime>(endsAt);
    return map;
  }

  CampaignRecordsCompanion toCompanion(bool nullToAbsent) {
    return CampaignRecordsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      startsAt: Value(startsAt),
      endsAt: Value(endsAt),
    );
  }

  factory CampaignRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CampaignRecord(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      startsAt: serializer.fromJson<DateTime>(json['startsAt']),
      endsAt: serializer.fromJson<DateTime>(json['endsAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'startsAt': serializer.toJson<DateTime>(startsAt),
      'endsAt': serializer.toJson<DateTime>(endsAt),
    };
  }

  CampaignRecord copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startsAt,
    DateTime? endsAt,
  }) => CampaignRecord(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt ?? this.endsAt,
  );
  CampaignRecord copyWithCompanion(CampaignRecordsCompanion data) {
    return CampaignRecord(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      startsAt: data.startsAt.present ? data.startsAt.value : this.startsAt,
      endsAt: data.endsAt.present ? data.endsAt.value : this.endsAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CampaignRecord(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startsAt: $startsAt, ')
          ..write('endsAt: $endsAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, startsAt, endsAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CampaignRecord &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.startsAt == this.startsAt &&
          other.endsAt == this.endsAt);
}

class CampaignRecordsCompanion extends UpdateCompanion<CampaignRecord> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime> startsAt;
  final Value<DateTime> endsAt;
  final Value<int> rowid;
  const CampaignRecordsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.endsAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CampaignRecordsCompanion.insert({
    required String id,
    required String title,
    required String description,
    required DateTime startsAt,
    required DateTime endsAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       description = Value(description),
       startsAt = Value(startsAt),
       endsAt = Value(endsAt);
  static Insertable<CampaignRecord> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? startsAt,
    Expression<DateTime>? endsAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (startsAt != null) 'starts_at': startsAt,
      if (endsAt != null) 'ends_at': endsAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CampaignRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<DateTime>? startsAt,
    Value<DateTime>? endsAt,
    Value<int>? rowid,
  }) {
    return CampaignRecordsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
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
    if (startsAt.present) {
      map['starts_at'] = Variable<DateTime>(startsAt.value);
    }
    if (endsAt.present) {
      map['ends_at'] = Variable<DateTime>(endsAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CampaignRecordsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startsAt: $startsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CouponRecordsTable extends CouponRecords
    with TableInfo<$CouponRecordsTable, CouponRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CouponRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campaignTitleMeta = const VerificationMeta(
    'campaignTitle',
  );
  @override
  late final GeneratedColumn<String> campaignTitle = GeneratedColumn<String>(
    'campaign_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRedeemedMeta = const VerificationMeta(
    'isRedeemed',
  );
  @override
  late final GeneratedColumn<bool> isRedeemed = GeneratedColumn<bool>(
    'is_redeemed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_redeemed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    campaignTitle,
    amount,
    quantity,
    expiresAt,
    isRedeemed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'coupon_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CouponRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('campaign_title')) {
      context.handle(
        _campaignTitleMeta,
        campaignTitle.isAcceptableOrUnknown(
          data['campaign_title']!,
          _campaignTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_campaignTitleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('is_redeemed')) {
      context.handle(
        _isRedeemedMeta,
        isRedeemed.isAcceptableOrUnknown(data['is_redeemed']!, _isRedeemedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CouponRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CouponRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      campaignTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campaign_title'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      isRedeemed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_redeemed'],
      )!,
    );
  }

  @override
  $CouponRecordsTable createAlias(String alias) {
    return $CouponRecordsTable(attachedDatabase, alias);
  }
}

class CouponRecord extends DataClass implements Insertable<CouponRecord> {
  final String id;
  final String code;
  final String campaignTitle;
  final int amount;
  final int quantity;
  final DateTime expiresAt;
  final bool isRedeemed;
  const CouponRecord({
    required this.id,
    required this.code,
    required this.campaignTitle,
    required this.amount,
    required this.quantity,
    required this.expiresAt,
    required this.isRedeemed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['campaign_title'] = Variable<String>(campaignTitle);
    map['amount'] = Variable<int>(amount);
    map['quantity'] = Variable<int>(quantity);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['is_redeemed'] = Variable<bool>(isRedeemed);
    return map;
  }

  CouponRecordsCompanion toCompanion(bool nullToAbsent) {
    return CouponRecordsCompanion(
      id: Value(id),
      code: Value(code),
      campaignTitle: Value(campaignTitle),
      amount: Value(amount),
      quantity: Value(quantity),
      expiresAt: Value(expiresAt),
      isRedeemed: Value(isRedeemed),
    );
  }

  factory CouponRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CouponRecord(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      campaignTitle: serializer.fromJson<String>(json['campaignTitle']),
      amount: serializer.fromJson<int>(json['amount']),
      quantity: serializer.fromJson<int>(json['quantity']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      isRedeemed: serializer.fromJson<bool>(json['isRedeemed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'campaignTitle': serializer.toJson<String>(campaignTitle),
      'amount': serializer.toJson<int>(amount),
      'quantity': serializer.toJson<int>(quantity),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'isRedeemed': serializer.toJson<bool>(isRedeemed),
    };
  }

  CouponRecord copyWith({
    String? id,
    String? code,
    String? campaignTitle,
    int? amount,
    int? quantity,
    DateTime? expiresAt,
    bool? isRedeemed,
  }) => CouponRecord(
    id: id ?? this.id,
    code: code ?? this.code,
    campaignTitle: campaignTitle ?? this.campaignTitle,
    amount: amount ?? this.amount,
    quantity: quantity ?? this.quantity,
    expiresAt: expiresAt ?? this.expiresAt,
    isRedeemed: isRedeemed ?? this.isRedeemed,
  );
  CouponRecord copyWithCompanion(CouponRecordsCompanion data) {
    return CouponRecord(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      campaignTitle: data.campaignTitle.present
          ? data.campaignTitle.value
          : this.campaignTitle,
      amount: data.amount.present ? data.amount.value : this.amount,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      isRedeemed: data.isRedeemed.present
          ? data.isRedeemed.value
          : this.isRedeemed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CouponRecord(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('campaignTitle: $campaignTitle, ')
          ..write('amount: $amount, ')
          ..write('quantity: $quantity, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('isRedeemed: $isRedeemed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    campaignTitle,
    amount,
    quantity,
    expiresAt,
    isRedeemed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CouponRecord &&
          other.id == this.id &&
          other.code == this.code &&
          other.campaignTitle == this.campaignTitle &&
          other.amount == this.amount &&
          other.quantity == this.quantity &&
          other.expiresAt == this.expiresAt &&
          other.isRedeemed == this.isRedeemed);
}

class CouponRecordsCompanion extends UpdateCompanion<CouponRecord> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> campaignTitle;
  final Value<int> amount;
  final Value<int> quantity;
  final Value<DateTime> expiresAt;
  final Value<bool> isRedeemed;
  final Value<int> rowid;
  const CouponRecordsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.campaignTitle = const Value.absent(),
    this.amount = const Value.absent(),
    this.quantity = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.isRedeemed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CouponRecordsCompanion.insert({
    required String id,
    required String code,
    required String campaignTitle,
    required int amount,
    required int quantity,
    required DateTime expiresAt,
    this.isRedeemed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       campaignTitle = Value(campaignTitle),
       amount = Value(amount),
       quantity = Value(quantity),
       expiresAt = Value(expiresAt);
  static Insertable<CouponRecord> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? campaignTitle,
    Expression<int>? amount,
    Expression<int>? quantity,
    Expression<DateTime>? expiresAt,
    Expression<bool>? isRedeemed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (campaignTitle != null) 'campaign_title': campaignTitle,
      if (amount != null) 'amount': amount,
      if (quantity != null) 'quantity': quantity,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (isRedeemed != null) 'is_redeemed': isRedeemed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CouponRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? campaignTitle,
    Value<int>? amount,
    Value<int>? quantity,
    Value<DateTime>? expiresAt,
    Value<bool>? isRedeemed,
    Value<int>? rowid,
  }) {
    return CouponRecordsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      campaignTitle: campaignTitle ?? this.campaignTitle,
      amount: amount ?? this.amount,
      quantity: quantity ?? this.quantity,
      expiresAt: expiresAt ?? this.expiresAt,
      isRedeemed: isRedeemed ?? this.isRedeemed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (campaignTitle.present) {
      map['campaign_title'] = Variable<String>(campaignTitle.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (isRedeemed.present) {
      map['is_redeemed'] = Variable<bool>(isRedeemed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CouponRecordsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('campaignTitle: $campaignTitle, ')
          ..write('amount: $amount, ')
          ..write('quantity: $quantity, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('isRedeemed: $isRedeemed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoyaltyRecordsTable extends LoyaltyRecords
    with TableInfo<$LoyaltyRecordsTable, LoyaltyRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoyaltyRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, points, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loyalty_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoyaltyRecord> instance, {
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
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    } else if (isInserting) {
      context.missing(_pointsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoyaltyRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoyaltyRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LoyaltyRecordsTable createAlias(String alias) {
    return $LoyaltyRecordsTable(attachedDatabase, alias);
  }
}

class LoyaltyRecord extends DataClass implements Insertable<LoyaltyRecord> {
  final String id;
  final String title;
  final int points;
  final DateTime createdAt;
  const LoyaltyRecord({
    required this.id,
    required this.title,
    required this.points,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['points'] = Variable<int>(points);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LoyaltyRecordsCompanion toCompanion(bool nullToAbsent) {
    return LoyaltyRecordsCompanion(
      id: Value(id),
      title: Value(title),
      points: Value(points),
      createdAt: Value(createdAt),
    );
  }

  factory LoyaltyRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoyaltyRecord(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      points: serializer.fromJson<int>(json['points']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'points': serializer.toJson<int>(points),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LoyaltyRecord copyWith({
    String? id,
    String? title,
    int? points,
    DateTime? createdAt,
  }) => LoyaltyRecord(
    id: id ?? this.id,
    title: title ?? this.title,
    points: points ?? this.points,
    createdAt: createdAt ?? this.createdAt,
  );
  LoyaltyRecord copyWithCompanion(LoyaltyRecordsCompanion data) {
    return LoyaltyRecord(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      points: data.points.present ? data.points.value : this.points,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoyaltyRecord(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('points: $points, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, points, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoyaltyRecord &&
          other.id == this.id &&
          other.title == this.title &&
          other.points == this.points &&
          other.createdAt == this.createdAt);
}

class LoyaltyRecordsCompanion extends UpdateCompanion<LoyaltyRecord> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> points;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LoyaltyRecordsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.points = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoyaltyRecordsCompanion.insert({
    required String id,
    required String title,
    required int points,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       points = Value(points),
       createdAt = Value(createdAt);
  static Insertable<LoyaltyRecord> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? points,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (points != null) 'points': points,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoyaltyRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? points,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LoyaltyRecordsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
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
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoyaltyRecordsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('points: $points, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppNotificationRecordsTable extends AppNotificationRecords
    with TableInfo<$AppNotificationRecordsTable, AppNotificationRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppNotificationRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, body, createdAt, isRead];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_notification_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppNotificationRecord> instance, {
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
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppNotificationRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppNotificationRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
    );
  }

  @override
  $AppNotificationRecordsTable createAlias(String alias) {
    return $AppNotificationRecordsTable(attachedDatabase, alias);
  }
}

class AppNotificationRecord extends DataClass
    implements Insertable<AppNotificationRecord> {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  const AppNotificationRecord({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_read'] = Variable<bool>(isRead);
    return map;
  }

  AppNotificationRecordsCompanion toCompanion(bool nullToAbsent) {
    return AppNotificationRecordsCompanion(
      id: Value(id),
      title: Value(title),
      body: Value(body),
      createdAt: Value(createdAt),
      isRead: Value(isRead),
    );
  }

  factory AppNotificationRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppNotificationRecord(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  AppNotificationRecord copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
  }) => AppNotificationRecord(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
    isRead: isRead ?? this.isRead,
  );
  AppNotificationRecord copyWithCompanion(
    AppNotificationRecordsCompanion data,
  ) {
    return AppNotificationRecord(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppNotificationRecord(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, body, createdAt, isRead);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppNotificationRecord &&
          other.id == this.id &&
          other.title == this.title &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.isRead == this.isRead);
}

class AppNotificationRecordsCompanion
    extends UpdateCompanion<AppNotificationRecord> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> body;
  final Value<DateTime> createdAt;
  final Value<bool> isRead;
  final Value<int> rowid;
  const AppNotificationRecordsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppNotificationRecordsCompanion.insert({
    required String id,
    required String title,
    required String body,
    required DateTime createdAt,
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<AppNotificationRecord> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
    Expression<bool>? isRead,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (isRead != null) 'is_read': isRead,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppNotificationRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? body,
    Value<DateTime>? createdAt,
    Value<bool>? isRead,
    Value<int>? rowid,
  }) {
    return AppNotificationRecordsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
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
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppNotificationRecordsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CampaignRecordsTable campaignRecords = $CampaignRecordsTable(
    this,
  );
  late final $CouponRecordsTable couponRecords = $CouponRecordsTable(this);
  late final $LoyaltyRecordsTable loyaltyRecords = $LoyaltyRecordsTable(this);
  late final $AppNotificationRecordsTable appNotificationRecords =
      $AppNotificationRecordsTable(this);
  late final CampaignDao campaignDao = CampaignDao(this as AppDatabase);
  late final CouponDao couponDao = CouponDao(this as AppDatabase);
  late final LoyaltyDao loyaltyDao = LoyaltyDao(this as AppDatabase);
  late final AppNotificationDao appNotificationDao = AppNotificationDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    campaignRecords,
    couponRecords,
    loyaltyRecords,
    appNotificationRecords,
  ];
}

typedef $$CampaignRecordsTableCreateCompanionBuilder =
    CampaignRecordsCompanion Function({
      required String id,
      required String title,
      required String description,
      required DateTime startsAt,
      required DateTime endsAt,
      Value<int> rowid,
    });
typedef $$CampaignRecordsTableUpdateCompanionBuilder =
    CampaignRecordsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<DateTime> startsAt,
      Value<DateTime> endsAt,
      Value<int> rowid,
    });

class $$CampaignRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CampaignRecordsTable> {
  $$CampaignRecordsTableFilterComposer({
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

  ColumnFilters<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CampaignRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CampaignRecordsTable> {
  $$CampaignRecordsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CampaignRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CampaignRecordsTable> {
  $$CampaignRecordsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get startsAt =>
      $composableBuilder(column: $table.startsAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endsAt =>
      $composableBuilder(column: $table.endsAt, builder: (column) => column);
}

class $$CampaignRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CampaignRecordsTable,
          CampaignRecord,
          $$CampaignRecordsTableFilterComposer,
          $$CampaignRecordsTableOrderingComposer,
          $$CampaignRecordsTableAnnotationComposer,
          $$CampaignRecordsTableCreateCompanionBuilder,
          $$CampaignRecordsTableUpdateCompanionBuilder,
          (
            CampaignRecord,
            BaseReferences<
              _$AppDatabase,
              $CampaignRecordsTable,
              CampaignRecord
            >,
          ),
          CampaignRecord,
          PrefetchHooks Function()
        > {
  $$CampaignRecordsTableTableManager(
    _$AppDatabase db,
    $CampaignRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CampaignRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CampaignRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CampaignRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> startsAt = const Value.absent(),
                Value<DateTime> endsAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampaignRecordsCompanion(
                id: id,
                title: title,
                description: description,
                startsAt: startsAt,
                endsAt: endsAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String description,
                required DateTime startsAt,
                required DateTime endsAt,
                Value<int> rowid = const Value.absent(),
              }) => CampaignRecordsCompanion.insert(
                id: id,
                title: title,
                description: description,
                startsAt: startsAt,
                endsAt: endsAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CampaignRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CampaignRecordsTable,
      CampaignRecord,
      $$CampaignRecordsTableFilterComposer,
      $$CampaignRecordsTableOrderingComposer,
      $$CampaignRecordsTableAnnotationComposer,
      $$CampaignRecordsTableCreateCompanionBuilder,
      $$CampaignRecordsTableUpdateCompanionBuilder,
      (
        CampaignRecord,
        BaseReferences<_$AppDatabase, $CampaignRecordsTable, CampaignRecord>,
      ),
      CampaignRecord,
      PrefetchHooks Function()
    >;
typedef $$CouponRecordsTableCreateCompanionBuilder =
    CouponRecordsCompanion Function({
      required String id,
      required String code,
      required String campaignTitle,
      required int amount,
      required int quantity,
      required DateTime expiresAt,
      Value<bool> isRedeemed,
      Value<int> rowid,
    });
typedef $$CouponRecordsTableUpdateCompanionBuilder =
    CouponRecordsCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> campaignTitle,
      Value<int> amount,
      Value<int> quantity,
      Value<DateTime> expiresAt,
      Value<bool> isRedeemed,
      Value<int> rowid,
    });

class $$CouponRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CouponRecordsTable> {
  $$CouponRecordsTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get campaignTitle => $composableBuilder(
    column: $table.campaignTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRedeemed => $composableBuilder(
    column: $table.isRedeemed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CouponRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CouponRecordsTable> {
  $$CouponRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get campaignTitle => $composableBuilder(
    column: $table.campaignTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRedeemed => $composableBuilder(
    column: $table.isRedeemed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CouponRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CouponRecordsTable> {
  $$CouponRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get campaignTitle => $composableBuilder(
    column: $table.campaignTitle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<bool> get isRedeemed => $composableBuilder(
    column: $table.isRedeemed,
    builder: (column) => column,
  );
}

class $$CouponRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CouponRecordsTable,
          CouponRecord,
          $$CouponRecordsTableFilterComposer,
          $$CouponRecordsTableOrderingComposer,
          $$CouponRecordsTableAnnotationComposer,
          $$CouponRecordsTableCreateCompanionBuilder,
          $$CouponRecordsTableUpdateCompanionBuilder,
          (
            CouponRecord,
            BaseReferences<_$AppDatabase, $CouponRecordsTable, CouponRecord>,
          ),
          CouponRecord,
          PrefetchHooks Function()
        > {
  $$CouponRecordsTableTableManager(_$AppDatabase db, $CouponRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CouponRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CouponRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CouponRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> campaignTitle = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<bool> isRedeemed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CouponRecordsCompanion(
                id: id,
                code: code,
                campaignTitle: campaignTitle,
                amount: amount,
                quantity: quantity,
                expiresAt: expiresAt,
                isRedeemed: isRedeemed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String campaignTitle,
                required int amount,
                required int quantity,
                required DateTime expiresAt,
                Value<bool> isRedeemed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CouponRecordsCompanion.insert(
                id: id,
                code: code,
                campaignTitle: campaignTitle,
                amount: amount,
                quantity: quantity,
                expiresAt: expiresAt,
                isRedeemed: isRedeemed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CouponRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CouponRecordsTable,
      CouponRecord,
      $$CouponRecordsTableFilterComposer,
      $$CouponRecordsTableOrderingComposer,
      $$CouponRecordsTableAnnotationComposer,
      $$CouponRecordsTableCreateCompanionBuilder,
      $$CouponRecordsTableUpdateCompanionBuilder,
      (
        CouponRecord,
        BaseReferences<_$AppDatabase, $CouponRecordsTable, CouponRecord>,
      ),
      CouponRecord,
      PrefetchHooks Function()
    >;
typedef $$LoyaltyRecordsTableCreateCompanionBuilder =
    LoyaltyRecordsCompanion Function({
      required String id,
      required String title,
      required int points,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LoyaltyRecordsTableUpdateCompanionBuilder =
    LoyaltyRecordsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> points,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LoyaltyRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $LoyaltyRecordsTable> {
  $$LoyaltyRecordsTableFilterComposer({
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

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LoyaltyRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $LoyaltyRecordsTable> {
  $$LoyaltyRecordsTableOrderingComposer({
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

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LoyaltyRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoyaltyRecordsTable> {
  $$LoyaltyRecordsTableAnnotationComposer({
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

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LoyaltyRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoyaltyRecordsTable,
          LoyaltyRecord,
          $$LoyaltyRecordsTableFilterComposer,
          $$LoyaltyRecordsTableOrderingComposer,
          $$LoyaltyRecordsTableAnnotationComposer,
          $$LoyaltyRecordsTableCreateCompanionBuilder,
          $$LoyaltyRecordsTableUpdateCompanionBuilder,
          (
            LoyaltyRecord,
            BaseReferences<_$AppDatabase, $LoyaltyRecordsTable, LoyaltyRecord>,
          ),
          LoyaltyRecord,
          PrefetchHooks Function()
        > {
  $$LoyaltyRecordsTableTableManager(
    _$AppDatabase db,
    $LoyaltyRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoyaltyRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoyaltyRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoyaltyRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> points = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoyaltyRecordsCompanion(
                id: id,
                title: title,
                points: points,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required int points,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LoyaltyRecordsCompanion.insert(
                id: id,
                title: title,
                points: points,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LoyaltyRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoyaltyRecordsTable,
      LoyaltyRecord,
      $$LoyaltyRecordsTableFilterComposer,
      $$LoyaltyRecordsTableOrderingComposer,
      $$LoyaltyRecordsTableAnnotationComposer,
      $$LoyaltyRecordsTableCreateCompanionBuilder,
      $$LoyaltyRecordsTableUpdateCompanionBuilder,
      (
        LoyaltyRecord,
        BaseReferences<_$AppDatabase, $LoyaltyRecordsTable, LoyaltyRecord>,
      ),
      LoyaltyRecord,
      PrefetchHooks Function()
    >;
typedef $$AppNotificationRecordsTableCreateCompanionBuilder =
    AppNotificationRecordsCompanion Function({
      required String id,
      required String title,
      required String body,
      required DateTime createdAt,
      Value<bool> isRead,
      Value<int> rowid,
    });
typedef $$AppNotificationRecordsTableUpdateCompanionBuilder =
    AppNotificationRecordsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> body,
      Value<DateTime> createdAt,
      Value<bool> isRead,
      Value<int> rowid,
    });

class $$AppNotificationRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AppNotificationRecordsTable> {
  $$AppNotificationRecordsTableFilterComposer({
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

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppNotificationRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppNotificationRecordsTable> {
  $$AppNotificationRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppNotificationRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppNotificationRecordsTable> {
  $$AppNotificationRecordsTableAnnotationComposer({
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

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);
}

class $$AppNotificationRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppNotificationRecordsTable,
          AppNotificationRecord,
          $$AppNotificationRecordsTableFilterComposer,
          $$AppNotificationRecordsTableOrderingComposer,
          $$AppNotificationRecordsTableAnnotationComposer,
          $$AppNotificationRecordsTableCreateCompanionBuilder,
          $$AppNotificationRecordsTableUpdateCompanionBuilder,
          (
            AppNotificationRecord,
            BaseReferences<
              _$AppDatabase,
              $AppNotificationRecordsTable,
              AppNotificationRecord
            >,
          ),
          AppNotificationRecord,
          PrefetchHooks Function()
        > {
  $$AppNotificationRecordsTableTableManager(
    _$AppDatabase db,
    $AppNotificationRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppNotificationRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AppNotificationRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AppNotificationRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppNotificationRecordsCompanion(
                id: id,
                title: title,
                body: body,
                createdAt: createdAt,
                isRead: isRead,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String body,
                required DateTime createdAt,
                Value<bool> isRead = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppNotificationRecordsCompanion.insert(
                id: id,
                title: title,
                body: body,
                createdAt: createdAt,
                isRead: isRead,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppNotificationRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppNotificationRecordsTable,
      AppNotificationRecord,
      $$AppNotificationRecordsTableFilterComposer,
      $$AppNotificationRecordsTableOrderingComposer,
      $$AppNotificationRecordsTableAnnotationComposer,
      $$AppNotificationRecordsTableCreateCompanionBuilder,
      $$AppNotificationRecordsTableUpdateCompanionBuilder,
      (
        AppNotificationRecord,
        BaseReferences<
          _$AppDatabase,
          $AppNotificationRecordsTable,
          AppNotificationRecord
        >,
      ),
      AppNotificationRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CampaignRecordsTableTableManager get campaignRecords =>
      $$CampaignRecordsTableTableManager(_db, _db.campaignRecords);
  $$CouponRecordsTableTableManager get couponRecords =>
      $$CouponRecordsTableTableManager(_db, _db.couponRecords);
  $$LoyaltyRecordsTableTableManager get loyaltyRecords =>
      $$LoyaltyRecordsTableTableManager(_db, _db.loyaltyRecords);
  $$AppNotificationRecordsTableTableManager get appNotificationRecords =>
      $$AppNotificationRecordsTableTableManager(
        _db,
        _db.appNotificationRecords,
      );
}

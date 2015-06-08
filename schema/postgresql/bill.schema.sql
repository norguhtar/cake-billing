-- This cake-billing is made available under Open Database License whose 
-- full text can be found at http://opendatacommons.org/licenses/odbl/. Any rights in 
-- individual contents of the database are licensed under the Database Contents 
-- License whose text can be found http://opendatacommons.org/licenses/dbcl/

CREATE SCHEMA bill;

CREATE TABLE bill.ledgertype (
                sid VARCHAR NOT NULL,
                name VARCHAR NOT NULL,
                CONSTRAINT bill_ledgertype_pk PRIMARY KEY (sid)
);
COMMENT ON TABLE bill.ledgertype IS 'Тип бухгалтерского счета';


CREATE SEQUENCE bill.vatrate_id_seq;

CREATE TABLE bill.vatrate (
                id BIGINT NOT NULL DEFAULT nextval('bill.vatrate_id_seq'),
                percent NUMERIC(10,2) NOT NULL,
                dtfrom DATE NOT NULL,
                dtto DATE,
                CONSTRAINT vatrate_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.vatrate IS 'Ставка налога на добавленную стоимость';
COMMENT ON COLUMN bill.vatrate.percent IS 'Ставка НДС в процентах';
COMMENT ON COLUMN bill.vatrate.dtfrom IS 'Начало действия ставки НДС';
COMMENT ON COLUMN bill.vatrate.dtto IS 'Дата завершения действия ставки НДС';


ALTER SEQUENCE bill.vatrate_id_seq OWNED BY bill.vatrate.id;

CREATE SEQUENCE bill.paymenttype_id_seq;

CREATE TABLE bill.paymenttype (
                id BIGINT NOT NULL DEFAULT nextval('bill.paymenttype_id_seq'),
                name VARCHAR NOT NULL,
                CONSTRAINT paymenttype_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.paymenttype IS 'Типы платежей';


ALTER SEQUENCE bill.paymenttype_id_seq OWNED BY bill.paymenttype.id;

CREATE SEQUENCE bill.unit_id_seq;

CREATE TABLE bill.unit (
                id BIGINT NOT NULL DEFAULT nextval('bill.unit_id_seq'),
                name VARCHAR NOT NULL,
                longname VARCHAR NOT NULL,
                basis BIGINT,
                id_parent BIGINT,
                CONSTRAINT unit_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.unit IS 'Единицы измерений';


ALTER SEQUENCE bill.unit_id_seq OWNED BY bill.unit.id;

CREATE SEQUENCE bill.service_id_seq;

CREATE TABLE bill.service (
                id BIGINT NOT NULL DEFAULT nextval('bill.service_id_seq'),
                id_unit BIGINT NOT NULL,
                name VARCHAR NOT NULL,
                sid_external VARCHAR,
                note VARCHAR NOT NULL,
                CONSTRAINT service_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.service IS 'Услуги';
COMMENT ON COLUMN bill.service.sid_external IS 'Идентификатор для связи с внешними системами';


ALTER SEQUENCE bill.service_id_seq OWNED BY bill.service.id;

CREATE SEQUENCE bill.price_id_seq;

CREATE TABLE bill.price (
                id BIGINT NOT NULL DEFAULT nextval('bill.price_id_seq'),
                id_service BIGINT NOT NULL,
                dtfrom DATE NOT NULL,
                dtto DATE,
                amount NUMERIC(10,2) NOT NULL,
                CONSTRAINT price_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.price IS 'Стоимость услуг';


ALTER SEQUENCE bill.price_id_seq OWNED BY bill.price.id;

CREATE TABLE bill.trxtype (
                sid VARCHAR NOT NULL,
                name VARCHAR NOT NULL,
                sid_ledgertype VARCHAR NOT NULL,
                optype VARCHAR NOT NULL,
                CONSTRAINT trxtype_pk PRIMARY KEY (sid)
);
COMMENT ON TABLE bill.trxtype IS 'Тип проведенных операций';
COMMENT ON COLUMN bill.trxtype.optype IS 'Тип операции';


CREATE SEQUENCE bill.period_id_seq;

CREATE TABLE bill.period (
                id BIGINT NOT NULL DEFAULT nextval('bill.period_id_seq'),
                dtfrom DATE NOT NULL,
                dtto DATE NOT NULL,
                tsclose TIMESTAMP,
                closed BOOLEAN DEFAULT false NOT NULL,
                CONSTRAINT period_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.period IS 'Бухгалтерские (отчетные) периоды';


ALTER SEQUENCE bill.period_id_seq OWNED BY bill.period.id;

CREATE SEQUENCE bill.contract_id_seq;

CREATE TABLE bill.contract (
                id BIGINT NOT NULL DEFAULT nextval('bill.contract_id_seq'),
                number BIGINT NOT NULL,
                balance NUMERIC(18,4) NOT NULL,
                dtfrom DATE NOT NULL,
                dtto DATE,
                note VARCHAR,
                CONSTRAINT contract_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.contract IS 'Договора с клиентами';
COMMENT ON COLUMN bill.contract.dtfrom IS 'Дата начала действия договора';
COMMENT ON COLUMN bill.contract.dtto IS 'Дата завершения действия договора. Если не заполнена, договор с прологнацией';


ALTER SEQUENCE bill.contract_id_seq OWNED BY bill.contract.id;

CREATE SEQUENCE bill.saldo_id_seq;

CREATE TABLE bill.saldo (
                id BIGINT NOT NULL DEFAULT nextval('bill.saldo_id_seq'),
                id_contract BIGINT NOT NULL,
                id_period BIGINT NOT NULL,
                openingbalance NUMERIC(18,4) NOT NULL,
                debet NUMERIC(18,4) NOT NULL,
                credit NUMERIC(18,4) NOT NULL,
                closingbalance NUMERIC(18,4) NOT NULL,
                CONSTRAINT saldo_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.saldo IS 'Обороты (сальдо) за период';
COMMENT ON COLUMN bill.saldo.openingbalance IS 'Баланс на начало периода';
COMMENT ON COLUMN bill.saldo.debet IS 'Дебетовое сальдо за период';
COMMENT ON COLUMN bill.saldo.credit IS 'Кредитовое сальдо за период';
COMMENT ON COLUMN bill.saldo.closingbalance IS 'Баланс на конец периода';


ALTER SEQUENCE bill.saldo_id_seq OWNED BY bill.saldo.id;

CREATE SEQUENCE bill.invoice_id_seq;

CREATE TABLE bill.invoice (
                id BIGINT NOT NULL DEFAULT nextval('bill.invoice_id_seq'),
                id_contract BIGINT NOT NULL,
                id_period BIGINT NOT NULL,
                dt DATE NOT NULL,
                dtcreate DATE NOT NULL,
                payed BOOLEAN DEFAULT false NOT NULL,
                CONSTRAINT invoice_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.invoice IS 'Документы к оплате';


ALTER SEQUENCE bill.invoice_id_seq OWNED BY bill.invoice.id;

CREATE SEQUENCE bill.trx_id_seq;

CREATE TABLE bill.trx (
                id BIGINT NOT NULL DEFAULT nextval('bill.trx_id_seq'),
                sid_ledgertype VARCHAR NOT NULL,
                sid_trxtype VARCHAR NOT NULL,
                id_period BIGINT NOT NULL,
                id_contract BIGINT NOT NULL,
                ts TIMESTAMP DEFAULT now() NOT NULL,
                tscreate TIMESTAMP DEFAULT now() NOT NULL,
                amount NUMERIC(18,2) NOT NULL,
                count DOUBLE PRECISION DEFAULT 1,
                CONSTRAINT trx_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.trx IS 'Проводки';
COMMENT ON COLUMN bill.trx.ts IS 'Дата и время проводки';


ALTER SEQUENCE bill.trx_id_seq OWNED BY bill.trx.id;

CREATE SEQUENCE bill.balance_id_seq;

CREATE TABLE bill.balance (
                id BIGINT NOT NULL DEFAULT nextval('bill.balance_id_seq'),
                id_contract BIGINT NOT NULL,
                id_trx BIGINT NOT NULL,
                tsfrom TIMESTAMP NOT NULL,
                tsto TIMESTAMP NOT NULL,
                balance NUMERIC(18,4) NOT NULL,
                CONSTRAINT balance_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.balance IS 'История изменения баланса';


ALTER SEQUENCE bill.balance_id_seq OWNED BY bill.balance.id;

CREATE SEQUENCE bill.invoice_cover_trx_id_seq;

CREATE TABLE bill.invoice_cover_trx (
                id BIGINT NOT NULL DEFAULT nextval('bill.invoice_cover_trx_id_seq'),
                id_trx BIGINT NOT NULL,
                id_invoice BIGINT NOT NULL,
                amount NUMERIC(18,4) NOT NULL,
                CONSTRAINT invoce_cover_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.invoice_cover_trx IS 'Покрытие счетов платежами';


ALTER SEQUENCE bill.invoice_cover_trx_id_seq OWNED BY bill.invoice_cover_trx.id;

CREATE SEQUENCE bill.invoice_trx_id_seq;

CREATE TABLE bill.invoice_trx (
                id BIGINT NOT NULL DEFAULT nextval('bill.invoice_trx_id_seq'),
                id_trx BIGINT NOT NULL,
                id_invoice BIGINT NOT NULL,
                CONSTRAINT invoice_trx_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.invoice_trx IS 'Начисления включенные в счет';


ALTER SEQUENCE bill.invoice_trx_id_seq OWNED BY bill.invoice_trx.id;

CREATE SEQUENCE bill.transfer_id_seq;

CREATE TABLE bill.transfer (
                id BIGINT NOT NULL DEFAULT nextval('bill.transfer_id_seq'),
                id_period BIGINT NOT NULL,
                id_contract_from BIGINT NOT NULL,
                id_contract_to BIGINT NOT NULL,
                id_trx_from BIGINT NOT NULL,
                id_trx_to BIGINT NOT NULL,
                id_revoke BIGINT NOT NULL,
                id_revokedby BIGINT NOT NULL,
                ts TIMESTAMP NOT NULL,
                tscreate TIMESTAMP NOT NULL,
                amount NUMERIC(18,4) NOT NULL,
                note VARCHAR NOT NULL,
                CONSTRAINT transfer_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.transfer IS 'Переносы денежных средств';


ALTER SEQUENCE bill.transfer_id_seq OWNED BY bill.transfer.id;

CREATE SEQUENCE bill.remain_id_seq;

CREATE TABLE bill.remain (
                id BIGINT NOT NULL DEFAULT nextval('bill.remain_id_seq'),
                sid_ledgertype VARCHAR NOT NULL,
                id_contract BIGINT NOT NULL,
                id_period BIGINT NOT NULL,
                id_trx BIGINT NOT NULL,
                id_revoke BIGINT,
                id_revokedby BIGINT,
                ts TIMESTAMP NOT NULL,
                tscreate TIMESTAMP NOT NULL,
                remain NUMERIC(18,4) NOT NULL,
                note VARCHAR,
                CONSTRAINT remain_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.remain IS 'Корректировки и остатки балансов возникающие при миграции';


ALTER SEQUENCE bill.remain_id_seq OWNED BY bill.remain.id;

CREATE SEQUENCE bill.charge_id_seq;

CREATE TABLE bill.charge (
                id BIGINT NOT NULL DEFAULT nextval('bill.charge_id_seq'),
                id_unit BIGINT NOT NULL,
                id_contract BIGINT NOT NULL,
                id_trx BIGINT NOT NULL,
                id_period BIGINT NOT NULL,
                id_service BIGINT NOT NULL,
                id_revoke BIGINT,
                id_revokedby BIGINT NOT NULL,
                vatincluded BOOLEAN DEFAULT FALSE,
                ts TIMESTAMP NOT NULL,
                tscreate TIMESTAMP NOT NULL,
                amount NUMERIC(18,4) NOT NULL,
                count DOUBLE PRECISION NOT NULL,
                note VARCHAR NOT NULL,
                CONSTRAINT charge_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.charge IS 'Начисления';
COMMENT ON COLUMN bill.charge.vatincluded IS 'Начисление включает НДС';


ALTER SEQUENCE bill.charge_id_seq OWNED BY bill.charge.id;


CREATE SEQUENCE bill.vat_id_seq;

CREATE TABLE bill.vat (
                id BIGINT NOT NULL DEFAULT nextval('bill.vat_id_seq'),
                id_vatrate BIGINT NOT NULL,
                id_charge BIGINT NOT NULL,
                id_trx BIGINT NOT NULL,
                id_period BIGINT NOT NULL,
                id_revoke BIGINT NOT NULL,
                id_revokedby BIGINT NOT NULL,
                ts TIMESTAMP DEFAULT now() NOT NULL,
                tscreate TIMESTAMP DEFAULT now() NOT NULL,
                amount NUMERIC(18,4) NOT NULL,
                CONSTRAINT vat_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.vat IS 'Документы НДС';


ALTER SEQUENCE bill.vat_id_seq OWNED BY bill.vat.id;

CREATE SEQUENCE bill.discount_id_seq;

CREATE TABLE bill.discount (
                id BIGINT NOT NULL DEFAULT nextval('bill.discount_id_seq'),
                id_contract BIGINT NOT NULL,
                id_period BIGINT NOT NULL,
                id_charge BIGINT NOT NULL,
                id_trx BIGINT NOT NULL,
                id_revoke BIGINT,
                id_revokedby BIGINT NOT NULL,
                ts TIMESTAMP NOT NULL,
                tscreate TIMESTAMP NOT NULL,
                amount NUMERIC(18,4) NOT NULL,
                CONSTRAINT discount_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.discount IS 'Скидки';


ALTER SEQUENCE bill.discount_id_seq OWNED BY bill.discount.id;

CREATE SEQUENCE bill.payment_id_seq;

CREATE TABLE bill.payment (
                id BIGINT NOT NULL DEFAULT nextval('bill.payment_id_seq'),
                sid_external VARCHAR,
                id_contract BIGINT NOT NULL,
                id_paymenttype BIGINT NOT NULL,
                id_period BIGINT NOT NULL,
                id_trx BIGINT NOT NULL,
                id_revoke BIGINT,
                id_revokedby BIGINT,
                ts TIMESTAMP NOT NULL,
                tscreate TIMESTAMP NOT NULL,
                tsagent TIMESTAMP,
                amount NUMERIC(18,4) NOT NULL,
                note VARCHAR NOT NULL,
                CONSTRAINT payment_pk PRIMARY KEY (id)
);
COMMENT ON TABLE bill.payment IS 'Платежи';
COMMENT ON COLUMN bill.payment.sid_external IS 'идентификатор во внешних системах';


ALTER SEQUENCE bill.payment_id_seq OWNED BY bill.payment.id;


ALTER TABLE bill.trxtype ADD CONSTRAINT ledgertype_trxtype_fk
FOREIGN KEY (sid_ledgertype)
REFERENCES bill.ledgertype (sid)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.trx ADD CONSTRAINT ledgertype_trx_fk
FOREIGN KEY (sid_ledgertype)
REFERENCES bill.ledgertype (sid)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.remain ADD CONSTRAINT ledgertype_remain_fk
FOREIGN KEY (sid_ledgertype)
REFERENCES bill.ledgertype (sid)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.vat ADD CONSTRAINT vatrate_vat_fk
FOREIGN KEY (id_vatrate)
REFERENCES bill.vatrate (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.payment ADD CONSTRAINT paymenttype_payment_fk
FOREIGN KEY (id_paymenttype)
REFERENCES bill.paymenttype (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.unit ADD CONSTRAINT parent_unit_fk
FOREIGN KEY (id_parent)
REFERENCES bill.unit (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.service ADD CONSTRAINT unit_service_fk
FOREIGN KEY (id_unit)
REFERENCES bill.unit (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.charge ADD CONSTRAINT unit_charge_fk
FOREIGN KEY (id_unit)
REFERENCES bill.unit (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.charge ADD CONSTRAINT service_charge_fk
FOREIGN KEY (id_service)
REFERENCES bill.service (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.price ADD CONSTRAINT service_price_fk
FOREIGN KEY (id_service)
REFERENCES bill.service (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.trx ADD CONSTRAINT trxtype_trx_fk
FOREIGN KEY (sid_trxtype)
REFERENCES bill.trxtype (sid)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.trx ADD CONSTRAINT period_trx_fk
FOREIGN KEY (id_period)
REFERENCES bill.period (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.payment ADD CONSTRAINT period_payment_fk
FOREIGN KEY (id_period)
REFERENCES bill.period (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.charge ADD CONSTRAINT period_charge_fk
FOREIGN KEY (id_period)
REFERENCES bill.period (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.remain ADD CONSTRAINT period_remain_fk
FOREIGN KEY (id_period)
REFERENCES bill.period (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.discount ADD CONSTRAINT period_discount_fk
FOREIGN KEY (id_period)
REFERENCES bill.period (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.transfer ADD CONSTRAINT period_transfer_fk
FOREIGN KEY (id_period)
REFERENCES bill.period (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.invoice ADD CONSTRAINT period_invoice_fk
FOREIGN KEY (id_period)
REFERENCES bill.period (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.vat ADD CONSTRAINT period_vat_fk
FOREIGN KEY (id_period)
REFERENCES bill.period (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.saldo ADD CONSTRAINT period_saldo_fk
FOREIGN KEY (id_period)
REFERENCES bill.period (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.trx ADD CONSTRAINT contract_trx_fk
FOREIGN KEY (id_contract)
REFERENCES bill.contract (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.payment ADD CONSTRAINT contract_payment_fk
FOREIGN KEY (id_contract)
REFERENCES bill.contract (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.charge ADD CONSTRAINT contract_charge_fk
FOREIGN KEY (id_contract)
REFERENCES bill.contract (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.remain ADD CONSTRAINT contract_remain_fk
FOREIGN KEY (id_contract)
REFERENCES bill.contract (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.discount ADD CONSTRAINT contract_discount_fk
FOREIGN KEY (id_contract)
REFERENCES bill.contract (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.transfer ADD CONSTRAINT contract_from_transfer_fk
FOREIGN KEY (id_contract_from)
REFERENCES bill.contract (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.transfer ADD CONSTRAINT contract_to_transfer_fk
FOREIGN KEY (id_contract_to)
REFERENCES bill.contract (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.balance ADD CONSTRAINT contract_balance_fk
FOREIGN KEY (id_contract)
REFERENCES bill.contract (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.invoice ADD CONSTRAINT contract_invoice_fk
FOREIGN KEY (id_contract)
REFERENCES bill.contract (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.saldo ADD CONSTRAINT contract_saldo_fk
FOREIGN KEY (id_contract)
REFERENCES bill.contract (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.invoice_trx ADD CONSTRAINT invoice_invoice_trx_fk
FOREIGN KEY (id_invoice)
REFERENCES bill.invoice (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.invoice_cover_trx ADD CONSTRAINT invoice_invoice_cover_trx_fk
FOREIGN KEY (id_invoice)
REFERENCES bill.invoice (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.payment ADD CONSTRAINT trx_payment_fk
FOREIGN KEY (id_trx)
REFERENCES bill.trx (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.charge ADD CONSTRAINT trx_charge_fk
FOREIGN KEY (id_trx)
REFERENCES bill.trx (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.remain ADD CONSTRAINT trx_remain_fk
FOREIGN KEY (id_trx)
REFERENCES bill.trx (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.discount ADD CONSTRAINT trx_discount_fk
FOREIGN KEY (id_trx)
REFERENCES bill.trx (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.transfer ADD CONSTRAINT trx_to_transfer_fk
FOREIGN KEY (id_trx_to)
REFERENCES bill.trx (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.transfer ADD CONSTRAINT trx_from_transfer_fk
FOREIGN KEY (id_trx_from)
REFERENCES bill.trx (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.invoice_trx ADD CONSTRAINT trx_invoice_trx_fk
FOREIGN KEY (id_trx)
REFERENCES bill.trx (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.invoice_cover_trx ADD CONSTRAINT trx_invoice_cover_trx_fk
FOREIGN KEY (id_trx)
REFERENCES bill.trx (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.balance ADD CONSTRAINT trx_balance_fk
FOREIGN KEY (id_trx)
REFERENCES bill.trx (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.vat ADD CONSTRAINT trx_vat_fk
FOREIGN KEY (id_trx)
REFERENCES bill.trx (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.transfer ADD CONSTRAINT revokedby_transfer_fk
FOREIGN KEY (id_revokedby)
REFERENCES bill.transfer (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.transfer ADD CONSTRAINT revoke_transfer_fk
FOREIGN KEY (id_revoke)
REFERENCES bill.transfer (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.remain ADD CONSTRAINT revoke_remain_fk
FOREIGN KEY (id_revoke)
REFERENCES bill.remain (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.remain ADD CONSTRAINT revokedby_remain_fk
FOREIGN KEY (id_revokedby)
REFERENCES bill.remain (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.charge ADD CONSTRAINT revoke_charge_fk
FOREIGN KEY (id_revoke)
REFERENCES bill.charge (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.charge ADD CONSTRAINT revockedby_charge_fk
FOREIGN KEY (id_revokedby)
REFERENCES bill.charge (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.discount ADD CONSTRAINT charge_discount_fk
FOREIGN KEY (id_charge)
REFERENCES bill.charge (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.vat ADD CONSTRAINT charge_vat_fk
FOREIGN KEY (id_charge)
REFERENCES bill.charge (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.vat ADD CONSTRAINT vat_revokedby_vat_fk
FOREIGN KEY (id_revokedby)
REFERENCES bill.vat (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.vat ADD CONSTRAINT vat_revoke_vat_fk
FOREIGN KEY (id_revoke)
REFERENCES bill.vat (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.discount ADD CONSTRAINT revokedby_discount_fk
FOREIGN KEY (id_revokedby)
REFERENCES bill.discount (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.discount ADD CONSTRAINT revoke_discount_fk
FOREIGN KEY (id_revoke)
REFERENCES bill.discount (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.payment ADD CONSTRAINT revoke_payment_fk
FOREIGN KEY (id_revoke)
REFERENCES bill.payment (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE bill.payment ADD CONSTRAINT revokedby_payment_fk
FOREIGN KEY (id_revokedby)
REFERENCES bill.payment (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

CREATE SCHEMA Melnikova

CREATE TABLE Melnikova.GOODS(
  GOOD_ID INTEGER NOT NULL,
  NAME_GOOD VARCHAR(200),
  AMOUNT_GOOD INTEGER,
  PRODUCTION_COST DOUBLE PRECISION CHECK (PRODUCTION_COST > 0),
  PRIMARY KEY(GOOD_ID)
);

CREATE TABLE Melnikova.SALES(
  SALE_ID INTEGER NOT NULL,
  DATE_OF_SALE DATE,
  REVENUE DOUBLE PRECISION CHECK (REVENUE > 0),
  NAME_CASHEIR VARCHAR(200),
  PRIMARY KEY(SALE_ID)
);

CREATE TABLE Melnikova.SUPPLIER(
  SUPPLIER_ID INTEGER NOT NULL,
  ADDRESS VARCHAR,
  PHONE VARCHAR(20),
  CONTACT_PERSON VARCHAR(200),
  BANK_DETAILS VARCHAR,
  PRIMARY KEY (SUPPLIER_ID)
);

CREATE TABLE Melnikova.PRODUCTION(
  MATERIAL_ID INTEGER NOT NULL,
  SUPPLIER_ID INTEGER NOT NULL,
  PRICE DOUBLE PRECISION CHECK (PRICE > 0),
  PRIMARY KEY(MATERIAL_ID),
  FOREIGN KEY (SUPPLIER_ID) REFERENCES Melnikova.SUPPLIER(SUPPLIER_ID)
);

CREATE TABLE  Melnikova.SALE_X_GOODS(
  GOOD_ID INTEGER NOT NULL,
  SALE_ID INTEGER NOT NULL,
  AMOUNT_GOODS INTEGER CHECK ( AMOUNT_GOODS > 0 ),
  PRIMARY KEY (GOOD_ID, SALE_ID),
  FOREIGN KEY (GOOD_ID) REFERENCES Melnikova.GOODS(GOOD_ID),
  FOREIGN KEY (SALE_ID) REFERENCES Melnikova.SALES(SALE_ID)
);

CREATE TABLE  Melnikova.GOODS_X_PRODUCTION(
  GOOD_ID INTEGER NOT NULL,
  MATERIAL_ID INTEGER NOT NULL,
  AMOUNT_USED_MATERIAL INTEGER CHECK ( AMOUNT_USED_MATERIAL > 0 ),
  PRIMARY KEY (GOOD_ID, MATERIAL_ID),
  FOREIGN KEY (GOOD_ID) REFERENCES Melnikova.GOODS(GOOD_ID),
  FOREIGN KEY (MATERIAL_ID) REFERENCES Melnikova.PRODUCTION(MATERIAL_ID)
);

INSERT INTO Melnikova.GOODS
VALUES (1, 'Пальто длинное', 9, 11000);
INSERT INTO Melnikova.GOODS
VALUES (2, 'Пальто короткое', 3, 9000);
INSERT INTO Melnikova.GOODS
VALUES (3, 'Свитер', 7, 6000);
INSERT INTO Melnikova.GOODS
VALUES (4, 'Куртка', 3, 5000);

INSERT INTO Melnikova.SUPPLIER
VALUES (1, 'Москва, ул.Московская 1', '88005553535', 'Иванов Иван Иванович', '1234 5678 9101 1213');
INSERT INTO Melnikova.SUPPLIER
VALUES (2, 'Москва, ул.Московская 11', '88005553536', 'Петров Петр Петрович', '1234 5678 9101 1214');


INSERT INTO Melnikova.PRODUCTION
VALUES (1, 1, 500);
INSERT INTO Melnikova.PRODUCTION
VALUES (2, 1, 160);
INSERT INTO Melnikova.PRODUCTION
VALUES (3, 2, 240);
INSERT INTO Melnikova.PRODUCTION
VALUES (4, 1, 4260);
INSERT INTO Melnikova.PRODUCTION
VALUES (5, 2, 4260);
INSERT INTO Melnikova.PRODUCTION
VALUES (6, 1, 900);

INSERT INTO Melnikova.SALES
VALUES (1, '2019-01-01', 11000, 'Галя');
INSERT INTO Melnikova.SALES
VALUES (2, '2019-01-02', 9000, 'Валя');
INSERT INTO Melnikova.SALES
VALUES (3, '2019-01-03', 6000, 'Галя');
INSERT INTO Melnikova.SALES
VALUES (4, '2019-01-04', 5000, 'Валя');
INSERT INTO Melnikova.SALES
VALUES (5, '2019-01-05', 16000, 'Галя');
INSERT INTO Melnikova.SALES
VALUES (6, '2019-01-06', 15000, 'Валя');
INSERT INTO Melnikova.SALES
VALUES (7, '2019-01-07', 10000, 'Галя');

INSERT INTO Melnikova.SALE_X_GOODS
VALUES (1, 1, 1);
INSERT INTO Melnikova.SALE_X_GOODS
VALUES (2, 2, 1);
INSERT INTO Melnikova.SALE_X_GOODS
VALUES (3, 3, 1);
INSERT INTO Melnikova.SALE_X_GOODS
VALUES (4, 4, 1);
INSERT INTO Melnikova.SALE_X_GOODS
VALUES (1, 5, 1);
INSERT INTO Melnikova.SALE_X_GOODS
VALUES (4, 5, 1);
INSERT INTO Melnikova.SALE_X_GOODS
VALUES (2, 6, 1);
INSERT INTO Melnikova.SALE_X_GOODS
VALUES (3, 6, 1);
INSERT INTO Melnikova.SALE_X_GOODS
VALUES (4, 7, 2);

INSERT INTO Melnikova.GOODS_X_PRODUCTION
VALUES (1, 4, 1);
INSERT INTO Melnikova.GOODS_X_PRODUCTION
VALUES (1, 2, 3);
INSERT INTO Melnikova.GOODS_X_PRODUCTION
VALUES (2, 5, 1);
INSERT INTO Melnikova.GOODS_X_PRODUCTION
VALUES (2, 2, 3);
INSERT INTO Melnikova.GOODS_X_PRODUCTION
VALUES (3, 6, 2);
INSERT INTO Melnikova.GOODS_X_PRODUCTION
VALUES (4, 1, 3);

/***************************************************************/
UPDATE Melnikova.SALES SET name_casheir = 'Катя' WHERE sale_id = 3 or sale_id = 6;

/*Имена продавцов, которые продали товара суммарно более, чем на 15000, в порядке убывания выручки */
SELECT name_casheir, SUM(revenue) AS sum
FROM Melnikova.sales
GROUP BY name_casheir
HAVING SUM(revenue) >= 15000
ORDER BY SUM(revenue) DESC;

/*Рейтинг товаров*/
SELECT good_id,
       SUM(amount_goods),
       row_number() OVER (ORDER BY SUM(amount_goods) DESC) AS rating
FROM Melnikova.SALE_X_GOODS
GROUP BY good_id
ORDER BY good_id;

/*Себестоимость товара*/
SELECT A.good_id, SUM(A.cost_price)
FROM (
       SELECT good_id,
              Melnikova.GOODS_X_PRODUCTION.MATERIAL_ID,
              Melnikova.GOODS_X_PRODUCTION.AMOUNT_USED_MATERIAL                                as amount,
              Melnikova.PRODUCTION.PRICE                                                       as price,
              (Melnikova.PRODUCTION.PRICE * Melnikova.GOODS_X_PRODUCTION.AMOUNT_USED_MATERIAL) as cost_price
       FROM Melnikova.GOODS_X_PRODUCTION
              INNER JOIN Melnikova.PRODUCTION
                         ON GOODS_X_PRODUCTION.material_id = PRODUCTION.material_id) AS A
GROUP BY A.good_id
ORDER BY good_id;


/*Выручка с продажи товара*/
SELECT A.good_id, A.name_good, SUM(A.revenue)
FROM (
       SELECT GOODS.good_id,
              name_good,
              production_cost,
              Melnikova.SALE_X_GOODS.AMOUNT_GOODS,
              (Melnikova.SALE_X_GOODS.AMOUNT_GOODS * production_cost) as revenue
       FROM Melnikova.GOODS
              INNER JOIN Melnikova.SALE_X_GOODS
                         ON GOODS.good_id = Melnikova.SALE_X_GOODS.good_id) AS A
GROUP BY A.good_id, A.name_good
ORDER BY good_id;

/*Чистая прибыль с каждого товара*/
SELECT R.good_id, (R.sum1 - R.sum2) as revenue
FROM (
       SELECT X.good_id, sum1, sum2
       FROM (
              SELECT A.good_id, A.name_good, SUM(A.revenue) as sum1
              FROM (
                     SELECT GOODS.good_id,
                            name_good,
                            production_cost,
                            Melnikova.SALE_X_GOODS.AMOUNT_GOODS,
                            (Melnikova.SALE_X_GOODS.AMOUNT_GOODS * production_cost) as revenue
                     FROM Melnikova.GOODS
                            INNER JOIN Melnikova.SALE_X_GOODS
                                       ON GOODS.good_id = Melnikova.SALE_X_GOODS.good_id) AS A
              GROUP BY A.good_id, A.name_good
            ) AS X
              INNER JOIN (
         SELECT A.good_id, SUM(A.cost_price) as sum2
         FROM (
                SELECT good_id,
                       Melnikova.GOODS_X_PRODUCTION.MATERIAL_ID,
                       Melnikova.GOODS_X_PRODUCTION.AMOUNT_USED_MATERIAL                                as amount,
                       Melnikova.PRODUCTION.PRICE                                                       as price,
                       (Melnikova.PRODUCTION.PRICE * Melnikova.GOODS_X_PRODUCTION.AMOUNT_USED_MATERIAL) as cost_price
                FROM Melnikova.GOODS_X_PRODUCTION
                       INNER JOIN Melnikova.PRODUCTION
                                  ON GOODS_X_PRODUCTION.material_id = PRODUCTION.material_id) AS A
         GROUP BY A.good_id
       ) AS Y
                         ON X.good_id = Y.good_id) as R
ORDER BY good_id;

/**********************************/

/*Информация о поставщике материала*/
CREATE VIEW Melnikova.info_material
AS
SELECT material_id, price, contact_person, phone, bank_details
FROM Melnikova.PRODUCTION,
     Melnikova.SUPPLIER
WHERE production.SUPPLIER_ID = supplier.supplier_id;


/*Товары с ценой выше среднего*/
CREATE VIEW Melnikova.goods_above_average_price AS
SELECT *
FROM Melnikova.GOODS
WHERE production_cost > (SELECT AVG(production_cost) FROM Melnikova.GOODS);


/*Статистика продаж*/
CREATE VIEW Melnikova.statistics_sales AS
SELECT GOODS.good_id, name_good, amount_sales
FROM Melnikova.GOODS,
     (SELECT good_id, SUM(amount_goods) as amount_sales
      FROM Melnikova.SALE_X_GOODS
      GROUP BY good_id) AS amount_sales_goods
WHERE GOODS.good_id = amount_sales_goods.good_id;


/*Информация о производстве товара*/
CREATE VIEW Melnikova.info_poduction_of_goods AS
SELECT name_good, GOODS_X_PRODUCTION.material_id, amount_used_material, price
FROM Melnikova.GOODS,
     Melnikova.GOODS_X_PRODUCTION,
     Melnikova.PRODUCTION
WHERE GOODS.good_id = GOODS_X_PRODUCTION.good_id
  and GOODS_X_PRODUCTION.material_id = PRODUCTION.material_id;

/*Себестоимость товара*/
CREATE VIEW Melnikova.cost_price AS
SELECT A.good_id, SUM(A.cost_price)
FROM (
       SELECT good_id,
              Melnikova.GOODS_X_PRODUCTION.MATERIAL_ID,
              Melnikova.GOODS_X_PRODUCTION.AMOUNT_USED_MATERIAL                                as amount,
              Melnikova.PRODUCTION.PRICE                                                       as price,
              (Melnikova.PRODUCTION.PRICE * Melnikova.GOODS_X_PRODUCTION.AMOUNT_USED_MATERIAL) as cost_price
       FROM Melnikova.GOODS_X_PRODUCTION
              INNER JOIN Melnikova.PRODUCTION
                         ON GOODS_X_PRODUCTION.material_id = PRODUCTION.material_id) AS A
GROUP BY A.good_id
ORDER BY good_id;


/*Финансы*/
CREATE VIEW Melnikova.finance AS
SELECT SUM((statistics_sales.amount_sales + goods.amount_good) * sum)                                      as expenses,
       SUM(statistics_sales.amount_sales * goods.production_cost)                                          as profit,
       SUM((statistics_sales.amount_sales * goods.production_cost) - ((statistics_sales.amount_sales + goods.amount_good) * sum)) as net_profit
FROM Melnikova.statistics_sales,
     Melnikova.GOODS,
     Melnikova.cost_price
WHERE statistics_sales.good_id = cost_price.good_id
  and goods.good_id = cost_price.good_id;


/*******************************************************/

/*Триггер обновляющий кол-во товара на складе, при insert-е в таблицу SALE_X_GOODS*/
CREATE OR REPLACE FUNCTION Melnikova.update_amount_goods() RETURNS TRIGGER AS
$$
BEGIN
  UPDATE Melnikova.GOODS
  SET AMOUNT_GOOD = AMOUNT_GOOD - NEW.amount_goods
  WHERE GOOD_ID = NEW.good_id;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Melnikova.amount_goods_update
  AFTER INSERT
  ON melnikova.sale_x_goods
  FOR EACH ROW
EXECUTE PROCEDURE update_amount_goods();

insert into Melnikova.SALE_X_GOODS values (2, 1, 2);


/* Хранимая процедура, возвращающая истину, если значение аргумента встречается в поле sale_id таблицы sales*/
CREATE OR REPLACE FUNCTION Melnikova.presence_check(id int)
  RETURNS boolean AS
$$
DECLARE
  result boolean;
BEGIN

  IF ((SELECT count(sale_id)
       FROM melnikova.sales
       WHERE sale_id = id) > 0)
  THEN
    result = true; --Значение id уже есть в таблице
  ELSE
    result = false;
  END IF;
  RETURN result;
END;
$$ LANGUAGE plpgsql;


/*Триггер, добавляющий и обновляющий строки в таблице sales
после внесения информации о продаже в таблицу sale_x_good*/

CREATE OR REPLACE FUNCTION Melnikova.update_sales() RETURNS TRIGGER AS
$$
BEGIN
  IF presence_check(NEW.sale_id) THEN
    UPDATE Melnikova.sales
    SET revenue = revenue +
                  NEW.amount_goods * (SELECT production_cost FROM Melnikova.goods WHERE goods.good_id = NEW.good_id)
    WHERE sale_id = NEW.sale_id;
  ELSE
    INSERT INTO Melnikova.sales
    VALUES (NEW.sale_id, NULL,
            NEW.amount_goods * (SELECT production_cost FROM Melnikova.goods WHERE goods.good_id = NEW.good_id), NULL);
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Melnikova.update_sales_table1
  BEFORE INSERT
  ON melnikova.sale_x_goods
  FOR EACH ROW
EXECUTE PROCEDURE update_sales();

insert into Melnikova.SALE_X_GOODS
values (4, 8, 5);
insert into Melnikova.SALE_X_GOODS
values (1, 2, 5);

/*Хранимая процедура, возвращающая себестоимость товара*/
CREATE OR REPLACE FUNCTION melnikova.cost_prise(id int)
  RETURNS int AS
$$
DECLARE
  result int;
BEGIN
  result = (SELECT B.sum
            FROM (SELECT A.good_id, SUM(A.cost_price) as sum
                  FROM (
                         SELECT good_id,
                                Melnikova.GOODS_X_PRODUCTION.MATERIAL_ID,
                                Melnikova.GOODS_X_PRODUCTION.AMOUNT_USED_MATERIAL                                as amount,
                                Melnikova.PRODUCTION.PRICE                                                       as price,
                                (Melnikova.PRODUCTION.PRICE *
                                 Melnikova.GOODS_X_PRODUCTION.AMOUNT_USED_MATERIAL)                              as cost_price
                         FROM Melnikova.GOODS_X_PRODUCTION
                                INNER JOIN Melnikova.PRODUCTION
                                           ON GOODS_X_PRODUCTION.material_id = PRODUCTION.material_id) AS A
                  GROUP BY A.good_id) AS B
            WHERE B.good_id = id);
  RETURN result;
END;
$$ LANGUAGE plpgsql;

select melnikova.cost_prise(1);

<?php

/**
 * Todos os objetos criados a partir do banco de dados
 * derivam desta classe.
 * Tanto as bicicletas quanto os administradores do site
 * derivam desta aqui.
 *
 * @author Leonardo Pinheiro
 */
class DatabaseObject {

    //----- START OF ACTIVE RECORD CODE -----

    /**
     *
     * @var mysqli Armazenará um objeto mysqli (com propriedades e métodos).
     */
    protected static $database;

    /**
     *
     * @var string Nome da tabela de onde serão extraídos os dados.
     */
    protected static $table_name = "";
    protected static $columns = [];

    /**
     *
     * @var string[] Array que contém todos os erros encontrados.
     */
    public $errors = [];

    public static function set_database($database) {
        self::$database = $database;
    }

    public static function find_by_sql($sql) {

        $result = self::$database->query($sql);
        if( !$result ) {
            exit("Database query failed.");
        }

        // results into objects
        $object_array = [];
        // Enquanto puder retirar linhas (registros) da tabela do banco de dados
        while( $record = $result->fetch_assoc() ) {
            // Apend no final do array de objetos
            $object_array[] = static::instantiate($record);
        }

        $result->free();

        return $object_array;

    }

    public static function find_all() {
        $sql = "SELECT * FROM " . static::$table_name;
        return static::find_by_sql($sql);
    }

    /**
     *
     * @return int O número de registros da tabela.
     */
    public static function count_all() {

        $sql = "SELECT COUNT(*) FROM " . static::$table_name;

        /* O resultado da query é uma única linha com uma única coluna.
         * Por isso, não há a necessidade de um array associativo.
         * Um array normal é o bastante */
        $result_set = self::$database->query($sql);
        $row = $result_set->fetch_array();

        // O primeiro valor dentro do array.
        return array_shift($row);

    }

    public static function find_by_id($id) {

        $sql  = "SELECT * FROM " . static::$table_name . " ";
                                                // Previne SQL injection.
        $sql .= "WHERE id='" . self::$database->escape_string($id) . "'";
        $obj_array = static::find_by_sql($sql);
        if( !empty($obj_array) ) {
            return array_shift($obj_array);
        } else {
            return FALSE;
        }

    }

    protected static function instantiate($record) {

        /* Cria uma nova instance de si mesma, ou seja,
         * cria um novo objeto da classe Bicycle. */
        $object = new static;
        // Could manually assign values to properties,
        // but automatically assignment is easier and re-usable.
        /* Para cada registro da tabela, como é um array associativo,
         * use o nome da coluna ($property) para obter o valor ($value). */
        foreach($record as $property => $value) {
            if( property_exists($object, $property) ) {
                $object->$property = $value;
            }
        }
        return $object;

    }

    /**
     * Valida os dados de inclusão e update do formulário.
     */
    protected function validate() {

        /* É uma boa prática começar sem erros, ou seja, com esse array vazio.
         * Também é conveniente que, se esse código rodar mais de uma vez,
         * não sejam gravados os mesmos erros mais de uma vez. */
        $this->errors = [];

        // Add custom validations

        // É uma boa prática sempre retornar um valor.
        return $this->errors;
    }

    protected function create() {

        /* Se não passar pela validação, ou seja, se o array erros
         * não estiver vazio, toda a criação é interrompida. */
        $this->validate();
        if( !empty( $this->errors ) ) {
            return FALSE;
        }

        // O tratamento dos dados só acontece se passar pela validação acima.
        $attributes = $this->sanitized_attributes();
        $sql  = "INSERT INTO " . static::$table_name . " (";
        $sql .= join( ', ', array_keys($attributes) );
        $sql .= ") VALUES ('";
        $sql .= join( "', '", array_values($attributes) );
        $sql .= "')";
        $result = self::$database->query($sql);

        if($result) {
            $this->id = self::$database->insert_id;
        }

        return $result;

    }

    protected function update() {

        /* Se não passar pela validação, ou seja, se o array erros
         * não estiver vazio, todo o update é interrompido. */
        $this->validate();
        if( !empty( $this->errors ) ) {
            return FALSE;
        }

        // O tratamento dos dados só acontece se passar pela validação acima.
        $attributes = $this->sanitized_attributes();
        $attribute_pairs = [];
        foreach($attributes as $key => $value) {
            $attribute_pairs[] = "{$key}='{$value}'";
        }

        $sql  = "UPDATE " . static::$table_name . " SET ";
        $sql .= join(', ', $attribute_pairs);
        $sql .= " WHERE id='" . self::$database->escape_string($this->id) . "' ";
        $sql .= "LIMIT 1";
        $result = self::$database->query($sql);
        return $result;

    }

    public function save() {

        // A new record will not have an ID yet
        if( isset($this->id) ) {
            return $this->update();
        } else {
            return $this->create();
        }

    }

    public function merge_attributes( $args=[] ) {

        foreach($args as $key => $value) {

            if( property_exists($this, $key) && !is_null($value) ) {
                $this->$key = $value;
            }

        }

    }

    // Properties which have database columns, excluding ID
    public function attributes() {

        $attributes = [];
        foreach(static::$db_columns as $column) {
            if($column == 'id') {
                continue;
            }
            $attributes[$column] = $this->$column;
        }
        return $attributes;

    }

    protected function sanitized_attributes() {

        $sanitized = [];
        foreach( $this->attributes() as $key => $value ) {
            $sanitized[$key] = self::$database->escape_string($value);
        }
        return $sanitized;

    }

    public function delete() {
        $sql  ="DELETE FROM " . static::$table_name . " ";
        $sql .= "WHERE id='" . self::$database->escape_string($this->id) . "' ";
        $sql .= "LIMIT 1";
        $result = self::$database->query($sql);
        return $result;

        /* After deleting, the instance of the object will still
         * exist, even though the database record does not.
         * This can be useful, as in:
         * echo $user->first_name . " was deleted.";
         * But, for example, we can't call $user->update() after
         * calling $user->delete(). */
    }

    //----- END OF ACTIVE RECORD CODE -----

}

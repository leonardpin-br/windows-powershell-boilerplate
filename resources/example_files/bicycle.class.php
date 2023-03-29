<?php

/**
 * Classe bicicleta da qual serão criados cada um dos objetos do mesmo tipo.
 *
 * @author Leonardo Pinheiro
 * @link https://stackoverflow.com/questions/15414103/best-way-to-document-array-options-in-phpdoc Best way to document Array options in PHPDoc?
 * @link https://github.com/phpDocumentor/phpDocumentor/issues/1813 Proposed syntax "string[]+int[]" for mixed array types.
 */
class Bicycle extends DatabaseObject {
    
    protected static $table_name = 'bicycles';
    
    // Array com as colunas do banco
    protected static $db_columns = [
        'id', 
        'brand', 
        'model', 
        'year', 
        'category', 
        'color', 
        'gender', 
        'price', 
        'weight_kg', 
        'condition_id', 
        'description'
    ];
    
    /*
     * As palavras-chave protected e public NAS CONSTANTES abaixo estão 
     * conflitando de alguma maneira com o PHPDoc, 
     * pois esta classe está sendo excluída da documentação.
     * Todo o restante é documentado sem problemas.
     * 
     * Essas são as linhas originais feitas a partir do curso:
     * protected const CONDITION_OPTIONS = [
     * public const CATEGORIES = ['Road', 'Mountain', 'Hybrid', 'Cruiser', 'City', 'BMX'];
     * public const GENDERS = ['Mens', 'Womens', 'Unisex'];
     */
  
    /**
     * Array com opções de estado das bicicletas.
     */
    const CONDITION_OPTIONS = [
        1=>'Beat up', 
        2=>'Decent', 
        3=>'Good', 
        4=>'Great', 
        5=>'Like New'
    ];
    
    /**
     * Categorias das bicicletas.
     */
    const CATEGORIES = ['Road', 'Mountain', 'Hybrid', 'Cruiser', 'City', 'BMX'];
    
    /**
     * Para qual tipo de público elas se destinam.
     */
    const GENDERS = ['Mens', 'Womens', 'Unisex'];
    
    public $id;
    public $brand;
    public $model;
    public $year;
    public $category;
    public $color;
    public $description;
    public $gender;
    public $price;
    
    /**
     *
     * @var int A massa (peso) é armazenada apenas em Kilogramas.
     */
    public $weight_kg;
    
    public $condition_id;
    
    /**
     * Construtor da classe Bicycle
     * @param array[] $args Array de argumentos (design pattern) para a criação do objeto.
     */
    public function __construct($args=[]) {
        
        // Forma anterior ao PHP 7 (ternary operator)
        // $this->brand = isset($args['brand']) ? $args['brand'] : '';
        
        // Forma atual de declaração
        $this->brand        = $args['brand']        ?? '';
        $this->model        = $args['model']        ?? '';
        $this->year         = $args['year']         ?? '';
        $this->category     = $args['category']     ?? '';
        $this->color        = $args['color']        ?? '';
        $this->description  = $args['description']  ?? '';
        $this->gender       = $args['gender']       ?? '';
        $this->price        = $args['price']        ?? 0;
        
        $this->weight_kg    = $args['weight_kg']    ?? 0.0;
        $this->condition_id = $args['condition_id'] ?? 3;
        
    }
    
    public function name() {
        return "{$this->brand} {$this->model} {$this->year}";
    }
    
    /**
     * 
     * @return string   O peso em Kilogramas
     */
    public function get_weight_kg() {
        return number_format($this->weight_kg, 2) . ' Kg';
    }
    
    /**
     * 
     * @param float $value  Define o peso em Kilogramas.
     */
    public function set_weight_kg($value) {
        $this->weight_kg = floatval($value);
    }
    
    /**
     * 
     * @return string O peso da bicicleta em libras.
     */
    public function get_weight_lbs() {
        $weight_lbs = floatval($this->weight_kg) * 2.2046226218;
        return number_format($weight_lbs, 2) . ' lbs';
    }
    
    /**
     * Define o peso da bicicleta (Armazenado, após conversão, em Kilogramas.).
     * @param float $value O peso da bicicleta em libras.
     */
    public function set_weight_lbs($value) {
        $this->weight_kg = floatval($value) / 2.2046226218;
    }
    
    /**
     * A condição na qual a bicicleta se encontra
     * @return string A condição da bicicleta.
     */
    public function condition() {

        if($this->condition_id > 0) {
            return self::CONDITION_OPTIONS[$this->condition_id];
        } else {
            return "Unknown";
        }
        
    }
    
    /**
     * Valida os dados de inclusão e update do formulário.
     */
    protected function validate() {
        
        /* É uma boa prática começar sem erros, ou seja, com esse array vazio.
         * Também é conveniente que, se esse código rodar mais de uma vez,
         * não sejam gravados os mesmos erros mais de uma vez. */
        $this->errors = [];
        
        if( is_blank( $this->brand) ) {
            $this->errors[] = "Brand cannot be blank.";
        }
        if( is_blank( $this->model) ) {
            $this->errors[] = "Model cannot be blank.";
        }
        
        // É uma boa prática sempre retornar um valor.
        return $this->errors;
    }
   
}

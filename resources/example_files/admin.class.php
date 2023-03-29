<?php
/**
 * A classe admin, assim como todas as que retiram informações 
 * do banco de dados, deriva da classe DatabaseObject.
 * 
 * @author Leonardo Pinheiro <info@leonardopinheiro.net>
 */
class Admin extends DatabaseObject {

    static protected $table_name = "admins";
    static protected $db_columns = [
        'id',
        'first_name',
        'last_name',
        'email',
        'username',
        'hashed_password'
    ];
    public $id;
    public $first_name;
    public $last_name;
    public $email;
    public $username;
    protected $hashed_password;
    public $password;
    public $confirm_password;
    protected $password_required = TRUE;

    public function __construct( $args = [] ) {
        $this->first_name       = $args['first_name'] ?? '';
        $this->last_name        = $args['last_name'] ?? '';
        $this->email            = $args['email'] ?? '';
        $this->username         = $args['username'] ?? '';
        $this->password         = $args['password'] ?? '';
        $this->confirm_password = $args['confirm_password'] ?? '';
    }

    public function full_name() {
        return $this->first_name . " " . $this->last_name;
    }

    protected function set_hashed_password() {
        $this->hashed_password = password_hash( $this->password, PASSWORD_BCRYPT );
    }
    
    public function verify_password( $password ) {
        return password_verify($password, $this->hashed_password);
    }

    /**
     * Override da função de mesmo nome da classe DatabaseObject.
     * Primeiro, executa o password hash, depois chama a função create() 
     * da parent class retornando TRUE ou FALSE.
     * 
     * @return boolean
     */
    protected function create() {
        $this->set_hashed_password();
        return parent::create();
    }

    protected function update() {
        /* Se a propriedade senha não estiver vazia (estiver 
         * sendo enviada no formulário), ou seja, se o admin estiver 
         * sendo incluído, ocorre a validação. 
         * Se o admin estiver sendo editado sem atualizar a senha, ou seja, sem 
         * enviar a senha no formulário, a validação não acontece. */
        if( $this->password != '' ) {
            $this->set_hashed_password();
            // validate password
        } else {
            // password not being updated, skip hashing and validation
            $this->password_required = FALSE;
        }
        return parent::update();
    }

    protected function validate() {
        $this->errors = [];

        if( is_blank( $this->first_name ) ) {
            $this->errors[] = "First name cannot be blank.";
        } elseif( !has_length( $this->first_name, array( 'min' => 2, 'max' => 255 ) ) ) {
            $this->errors[] = "First name must be between 2 and 255 characters.";
        }

        if( is_blank( $this->last_name ) ) {
            $this->errors[] = "Last name cannot be blank.";
        } elseif( !has_length( $this->last_name, array( 'min' => 2, 'max' => 255 ) ) ) {
            $this->errors[] = "Last name must be between 2 and 255 characters.";
        }

        if( is_blank( $this->email ) ) {
            $this->errors[] = "Email cannot be blank.";
        } elseif( !has_length( $this->email, array( 'max' => 255 ) ) ) {
            $this->errors[] = "Last name must be less than 255 characters.";
        } elseif( !has_valid_email_format( $this->email ) ) {
            $this->errors[] = "Email must be a valid format.";
        }

        if( is_blank( $this->username ) ) {
            $this->errors[] = "Username cannot be blank.";
        } elseif( !has_length( $this->username, array( 'min' => 8, 'max' => 255 ) ) ) {
            $this->errors[] = "Username must be between 8 and 255 characters.";
        } elseif( !has_unique_username( $this->username, $this->id ?? 0 ) ) {
            $this->errors[] = "Username not allowed. Try another.";
        }

        if( $this->password_required ) {
            
            if( is_blank( $this->password ) ) {
                $this->errors[] = "Password cannot be blank.";
            } elseif( !has_length( $this->password, array( 'min' => 12 ) ) ) {
                $this->errors[] = "Password must contain 12 or more characters";
            } elseif( !preg_match( '/[A-Z]/', $this->password ) ) {
                $this->errors[] = "Password must contain at least 1 uppercase letter";
            } elseif( !preg_match( '/[a-z]/', $this->password ) ) {
                $this->errors[] = "Password must contain at least 1 lowercase letter";
            } elseif( !preg_match( '/[0-9]/', $this->password ) ) {
                $this->errors[] = "Password must contain at least 1 number";
            } elseif( !preg_match( '/[^A-Za-z0-9\s]/', $this->password ) ) {
                $this->errors[] = "Password must contain at least 1 symbol";
            }

            if( is_blank( $this->confirm_password ) ) {
                $this->errors[] = "Confirm password cannot be blank.";
            } elseif( $this->password !== $this->confirm_password ) {
                $this->errors[] = "Password and confirm password must match.";
            }
            
        }
        
        return $this->errors;
    }

    /**
      * Validates uniqueness of admins.username
      * 
      * ```
      * has_unique_username('johnqpublic')
      * ```
      * 
      * For new records, provide only the username.
      * For existing records, provide current ID as second argument
      * has_unique_username('johnqpublic', 4)
      * 
      * @param String $username
      * @param int $current_id
      * @return boolean
      */
    public static function find_by_username( $username ) {
        $sql  = "SELECT * FROM " . static::$table_name . " ";
                                                // Previne SQL injection.
        $sql .= "WHERE username='" . self::$database->escape_string($username) . "'";
        $obj_array = static::find_by_sql($sql);
        if( !empty($obj_array) ) {
            return array_shift($obj_array);
        } else {
            return FALSE;
        }
    }
    
}

?>

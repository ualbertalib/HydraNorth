rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

# use config/redis.yml to load settings
redis_config_path = "#{rails_root}/config/redis.yml"
redis_config = YAML.load(ERB.new(IO.read(redis_config_path)).result)

# initialize redis connection
Resque.redis = redis_config[rails_env]

# pull out the parsed redis driver from resque
$redis = Resque.redis.instance_eval{@redis}

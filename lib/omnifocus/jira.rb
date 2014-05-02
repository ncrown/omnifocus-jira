require 'rubygems'
#require 'pp'
require 'jira'
require "open-uri"
require "json"
require "yaml"

module OmniFocus::Jira  
  PREFIX  = "JIRA"
  FOLDER  = "JIRA"
  
  def load_or_create_jira_config
    path   = File.expand_path "~/.omnifocus-jira.yml"
    config = YAML.load(File.read(path)) rescue nil
    
    unless config then
      config = { :username           => "john.doe", 
                 :password           => "123",
                 :site               => 'https://company.atlassian.net',        
                 :rest_base_path     => '/rest/api/2',
                 :context_path       => '',
                 :auth_type          => :basic,
                 :project_key        => 'PMM',
                 :jql_query          => 'project = #{project_key} AND assignee = #{username}'               
               }

      File.open(path, "w") { |f|
        YAML.dump(config, f)
      }

      abort "Created default config in #{path}. Go fill it out."
    end
    config
  end

  def populate_jira_tasks
    # 1. fetch jira issues    
    config = load_or_create_jira_config    
    #config.keys.each do |key|
    #  config[(key.to_sym rescue key) || key] = config.delete(key)
    #end
    
    # create the jira client
    client = JIRA::Client.new(config)  
        
    # query the issues with the supplied jql
    client.Issue.jql(config[:jql_query]).each do |issue|      
      # 2. process jira issues
      #puts "#{issue.id} - #{issue.fields['summary']}"
      project_name = issue.fields['project']['name']
      ticket_id = issue.key
      ticket_summary = issue.fields['summary']
      site = config[:site]
      url = "#{site}/browse/#{ticket_id}"

      if existing[ticket_id]
        project = existing[ticket_id]
        bug_db[project][ticket_id] = true
      else
        bug_db[project_name][ticket_id] = [ticket_summary, url]
      end
    end
  end
end
require 'rubygems'
#require 'pp'
require 'jira'
require "open-uri"
require "json"
require "yaml"

module OmniFocus::Jira  
  PREFIX  = "PMM"
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
      #component_name = issue.fields['components'][0]['name']
      project_name = issue.fields['project']['name']
      #project_name = "#{project_name} - #{component_name}"
      issue_key = issue.key
      issue_summary = issue.fields['summary']
      site = config[:site]
      url = "#{site}/browse/#{issue_key}"      

      if existing[issue_key]
        project = existing[issue_key]
        bug_db[project][issue_key] = true
      else
        bug_db[project_name][issue_key] = ["#{issue_key}: #{issue_summary}", url]
      end
    end
  end
end
require "open-uri"
require "json"
require "yaml"

require 'rubygems'
require 'pp'
require 'jira'


module OmniFocus::Jira  

  def load_or_create_jira_config
    path   = File.expand_path "~/.omnifocus-jira.yml"
    config = YAML.load(File.read(path)) rescue nil
    
    unless config then
      config = { :username           => "nick.crown", 
                 :password           => "123",
                 :site               => 'https://droidcloud.atlassian.net',        
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

    # create the jira client
    client = JIRA::Client.new(config)
    
    # query the issues with the supplied jql
    client.Issue.jql(config[:jql_query]).each do |issue|      
      #puts "#{issue.id} - #{issue.fields['summary']}"
      # 2. process jira issues
      # If card is in a "done" list, mark it as completed.
      project_name = issue.fields['project']['name']
      ticket_id = issue.key
      ticket_summary = issue.fields['summary']
      site = config(:site)
      url = "#{site}/browse/#{ticket_id}"

      if existing[ticket_id]
          project = existing[ticket_id]
          bug_db[project][ticket_id] = true
        else
          bug_db[project][ticket_id] = [ticket_summary, url]
      end      
    end
  end
end
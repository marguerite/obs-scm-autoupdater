#!/usr/bin/env ruby

require 'open3'
require 'date'

if ARGV.empty?

	# update current directory
	dir = Dir.pwd

	# can be made to a "precheck" function
	if Dir.glob(dir + "/_service").empty?
		if Dir.glob(dir + "/.osc").empty?
			abort "this is not an osc working directory"
		else
			abort "there's no _service file inside this directory"
		end
	else
		# will check if the _service file is scm
	end 

	# can be made to a "get_tarball" function {
	# osc delete the previous tarball, and make sure the delete is right
	keywords, specs, oldtars, newtars, existed = Array.new, Array.new, Array.new, Array.new, Array.new
	# get keywords from specfiles
	Dir.glob(dir + "/*.spec").each { |s| specs << s.gsub(/^.*\//,'').gsub(".spec",'') }
	specs.each {|s| s.split("-").each {|k| keywords << k }}
	keywords = ( keywords.uniq! if keywords.uniq! ) || keywords
	# get keywords from tarball
	Dir.glob(dir + "/*.{tar.*,tgz,bz2,gz}").each do |t|
		existed << t.gsub(/^.*\//,'')
		ta = t.gsub(/^.*\//,'').gsub(/\.(tar.*|tgz|bz2|gz)$/,'').split("-")
		# drop the last item because it represents version
		ta = ta.first(ta.size - 1) || ta
		ta = (ta.uniq! if ta.uniq!) || ta
		ta.each {|i| oldtars << i} 
	end
	
	unless oldtars.empty?
	# get the intersection
	keywords = keywords && oldtars
	# "openSUSE" can't be a keyword
	keywords = keywords.delete(/openSUSE/i) || keywords
	# use the intersection to determine the tar
	Dir.glob(dir + "/*.{tar.*,tgz,bz2,gz}").each do |t|
		ta = t.gsub(/^.*\//,'').gsub(/\.(tar.*|tgz|bz2|gz)$/,'').split("-")
                # drop the last item because it represents version
                ta = ta.first(ta.size - 1) || ta
                ta = (ta.uniq! if ta.uniq!) || ta
		# if the tarball array contains keywords
                ta.each {|i| newtars << t if keywords.include?(i)}
	end
	newtars = (newtars.uniq! if newtars.uniq!) || newtars
	# now we have the tarball's name
	tarball = newtars[0]
	# } get_tarball function

	# call osc command to delete the old tarball
	IO.popen("osc delete #{tarball.gsub(/^.*\//,'')}") unless File.exist?(tarball)
	end

	# call osc command to clean up specfile
	IO.popen("osc service localrun format_spec_file")
	IO.popen("spec-cleaner -i *.spec")

	# run the scm service
	# [hack] use popen3 to make sure the shell command exists first
	generated = String.new
	Open3.popen3('osc service disabledrun') do |stdin,stdout,stderr,wait_thr|
		puts "running service for #{dir.gsub(/^.*\//,'')}"
        	exit_status = wait_thr.value
		stdout.each {|l| puts l}
        	if exit_status == 0
			Dir.glob(dir + "/*.{tar.*,tgz,bz2,gz}").each do |t|
				generated = t unless existed.include?(t)
			end
			IO.popen("osc add #{generated}")
			IO.popen("osc add _servicedata") if Dir.glob(dir + "/_servicedata").empty?
			Open3.popen3("osc ci -m \"auto updated by obs-scm-autoupdater at #{Time.now}\"") do |stdin1,stdout1,stderr1,wait_thr1|
				stdout1.each {|l| puts l}
				exit_status1 = wait_thr1.value
				if exit_status1 == 0
					exit
				else
					sleep 1
				end
			end
		else
			abort "service failed! please manual run and fix it."
		end
	end
	p generated

else

end

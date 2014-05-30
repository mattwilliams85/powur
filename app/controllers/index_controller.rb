class IndexController < ApplicationController

	layout "landing"

	def promoter
		render layout: "user"
	end

	def customer
	end
	
end

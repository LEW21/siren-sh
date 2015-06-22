
module GollumAuth
	User = Struct.new(:name, :email, :password_sha512)

	class Middleware

		def initialize(app)
			@app = app
		end

		def call(env)
			request = Rack::Request.new(env)
			session = request.session

			if not session['gollum.author']
				authenticate(request)
			end

			if request.path =~ /^\/(edit|uploadFile|rename|delete|create|revert|preview|livepreview)(\/|$)/
				if not session['gollum.author']
					return Rack::Response.new('Login required', 401, {'WWW-Authenticate' => %(Basic realm="Gollum Wiki")})
				end
			end

			@app.call(env)
		end

		def authenticate(request)
			auth ||=  Rack::Auth::Basic::Request.new(request.env)
			if auth.provided? && auth.basic? && auth.credentials
				user = USERS.detect do |u|
					[u.name, u.email].include?(auth.credentials[0]) && 
					u.password_sha512 == Digest::SHA512.hexdigest(auth.credentials[1])
				end
				if user
					request.session['gollum.author'] = {
						:name => user.name,
						:email => user.email
					}
				end
			end
		end
	end
end
